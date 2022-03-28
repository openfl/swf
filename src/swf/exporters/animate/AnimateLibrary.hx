package swf.exporters.animate;

import haxe.Json;
import lime.graphics.Image;
import lime.graphics.ImageChannel;
import lime.math.Vector2;
import swf.exporters.core.FilterType;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.utils.Assets;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetType;
import openfl.utils.Future;
import openfl.utils.Promise;
#if lime
import lime.utils.AssetManifest;
#else
import openfl.utils.AssetManifest;
#end
// Extra imports to include at runtime
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ConvolutionFilter;
import openfl.filters.DisplacementMapFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(swf.exporters.animate.AnimateSpriteSymbol)
@:access(swf.exporters.animate)
@SuppressWarnings("checkstyle:FieldDocComment")
@:keep class AnimateLibrary extends AssetLibrary
{
	#if 0
	// Suppress checkstyle warning
	private static var __unusedImport:Array<Class<Dynamic>> = [
		ColorMatrixFilter,
		ConvolutionFilter,
		DisplacementMapFilter,
		DropShadowFilter,
		GlowFilter
	];
	#end

	private static var instances:Map<String, AnimateLibrary> = new Map();

	private var alphaCheck:Map<String, Bool>;
	private var bitmapClassNames:Map<String, String>;
	private var bitmapSymbols:Array<AnimateBitmapSymbol>;
	private var frameRate:Float;
	private var id:String;
	private var instanceID:String;
	private var preloading:Bool;
	private var root:AnimateSpriteSymbol;
	private var rootPath:String;
	private var symbols:Map<Int, AnimateSymbol>;
	private var symbolsByClassName:Map<String, AnimateSymbol>;
	private var uuid:String;

	public function new(id:String, uuid:String = null)
	{
		super();

		this.id = id;

		instanceID = uuid != null ? uuid : id;

		alphaCheck = new Map();
		bitmapClassNames = new Map();

		#if (ios || tvos)
		rootPath = "assets/";
		#else
		rootPath = "";
		#end

		instances.set(uuid, this);

		// Hack to include filter classes, macro.include is not working properly

		// var filter = flash.filters.BlurFilter;
		// var filter = flash.filters.DropShadowFilter;
		// var filter = flash.filters.GlowFilter;
	}

	#if (openfl > "9.1.0")
	public override function bind(className:String, instance:Dynamic = null):Bool
	{
		#if !flash
		var symbol = symbolsByClassName.get(className);
		if (symbol != null)
		{
			if (instance != null)
			{
				symbol.__initObject(this, instance);
			}
			else
			{
				symbol.__init(this);
			}
			return true;
		}
		#end
		return false;
	}
	#end

	#if lime
	public override function exists(id:String, type:String):Bool
	{
		if (symbols != null)
		{
			if (id == "" && type == (cast AssetType.MOVIE_CLIP))
			{
				return true;
			}

			if (type == null || type == (cast AssetType.IMAGE) || type == (cast AssetType.MOVIE_CLIP))
			{
				return (symbolsByClassName != null && symbolsByClassName.exists(id));
			}
		}

		return super.exists(id, type);
	}
	#end

	private static function get(uuid:String):AnimateLibrary
	{
		return instances.get(uuid);
	}

	#if lime
	public override function getImage(id:String):Image
	{
		if (bitmapClassNames.exists(id))
		{
			id = bitmapClassNames.get(id);
		}

		// TODO: Better system?

		if (!alphaCheck.exists(id))
		{
			for (bitmapSymbol in bitmapSymbols)
			{
				if (bitmapSymbol.path == id && bitmapSymbol.alpha != null)
				{
					var image = super.getImage(id);
					var alpha = super.getImage(bitmapSymbol.alpha);

					__copyChannel(image, alpha);

					cachedImages.set(id, image);
					cachedImages.remove(bitmapSymbol.alpha);
					alphaCheck.set(id, true);

					return image;
				}
			}
			alphaCheck.set(id, true);
		}

		return super.getImage(id);
	}
	#end

	#if lime
	public override function getMovieClip(id:String):MovieClip
	{
		if (symbols == null) return null;

		if (id == "")
		{
			return cast root.__createObject(this);
		}
		else
		{
			var symbol = symbolsByClassName.get(id);
			if (symbol != null)
			{
				if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (symbol, AnimateSpriteSymbol))
				{
					var sprite = cast(symbol, AnimateSpriteSymbol).__createObject(this);
					if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (sprite, MovieClip))
					{
						// May return a Sprite if there is a custom base class defined that uses
						// Sprite instead of MovieClip. In that case, access through new()
						return cast sprite;
					}
				}
			}
		}

		return null;
	}
	#end

	#if lime
	public override function isLocal(id:String, type:String):Bool
	{
		return true;
	}
	#end

	#if lime
	public override function load():Future<lime.utils.AssetLibrary>
	{
		if (id != null)
		{
			preload.set(id, true);
		}

		var promise = new Promise<lime.utils.AssetLibrary>();
		preloading = true;

		var onComplete = function(data)
		{
			cachedText.set(id, data);

			var json:Dynamic = Json.parse(data);
			var version = json.version;
			frameRate = json.frameRate;
			// uuid = json.uuid;
			var rootIndex = json.root;
			var symbolData:Array<Dynamic> = json.symbols;

			var data, type:SWFSymbolType, symbol:AnimateSymbol = null;
			var bitmapSymbol, spriteSymbol;

			symbols = new Map();
			symbolsByClassName = new Map();
			bitmapSymbols = new Array();

			for (i in 0...symbolData.length)
			{
				data = symbolData[i];
				if (data == null) continue;
				type = data.type;

				switch (type)
				{
					case BITMAP:
						bitmapSymbol = __parseBitmap(data);
						bitmapSymbols.push(bitmapSymbol);
						if (bitmapSymbol.className != null) bitmapClassNames.set(bitmapSymbol.className, bitmapSymbol.path);
						symbol = bitmapSymbol;
					case BUTTON:
						symbol = __parseButton(data);
					case DYNAMIC_TEXT:
						symbol = __parseDynamicText(data);
					case FONT:
						symbol = __parseFont(data);
					case SHAPE:
						symbol = __parseShape(data);
					case SPRITE:
						spriteSymbol = __parseSprite(data);
						if (i == rootIndex) root = spriteSymbol;
						symbol = spriteSymbol;
					case STATIC_TEXT:
						symbol = __parseStaticText(data);
					case MORPH_SHAPE:
						symbol = __parseMorphShape(data);
					default:
				}

				if (symbol == null) continue;
				symbols.set(symbol.id, symbol);
				if (symbol.className != null)
				{
					symbolsByClassName.set(symbol.className, symbol);
					#if (openfl > "9.1.0")
					Assets.registerBinding(symbol.className, this);
					#end
				}
			}

			// SWFLite.instances.set(instanceID, swf);

			__load().onProgress(promise.progress).onError(promise.error).onComplete(function(_)
			{
				preloading = false;
				promise.complete(this);
			});
		}

		if (exists(id, cast AssetType.TEXT) || exists(id, cast AssetType.BINARY))
		{
			#if web
			for (id in paths.keys())
			{
				preload.set(id, true);
			}

			for (id in types.keys())
			{
				if (types.get(id) == IMAGE)
				{
					preload.set(id, true);
				}
			}
			#end

			loadText(id).onError(promise.error).onComplete(onComplete);
		}
		else
		{
			for (id in paths.keys())
			{
				preload.set(id, true);
			}

			var path = null;

			if (paths.exists(id))
			{
				path = paths.get(id);
			}
			else
			{
				path = (rootPath != null && rootPath != "") ? rootPath + "/" + id : id;
			}

			var loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(_) onComplete(loader.data));
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e) promise.error(e));
			loader.load(new URLRequest(path));
		}

		return promise.future;
	}
	#end

	#if lime
	public override function loadImage(id:String):Future<Image>
	{
		if (bitmapClassNames.exists(id))
		{
			id = bitmapClassNames.get(id);
		}

		if (#if (swf_preload || swflite_preload) true #else !preloading #end && !alphaCheck.exists(id))
		{
			for (bitmapSymbol in bitmapSymbols)
			{
				if (bitmapSymbol.path == id && bitmapSymbol.alpha != null)
				{
					var promise = new Promise<Image>();

					__loadImage(id).onError(promise.error).onComplete(function(image)
					{
						__loadImage(bitmapSymbol.alpha).onError(promise.error).onComplete(function(alpha)
						{
							__copyChannel(image, alpha);

							cachedImages.set(id, image);
							cachedImages.remove(bitmapSymbol.alpha);
							alphaCheck.set(id, true);

							promise.complete(image);
						});
					});

					return promise.future;
				}
				else
				{
					alphaCheck.set(id, true);
				}
			}
		}

		return super.loadImage(id);
	}
	#end

	#if lime
	public override function unload():Void
	{
		instances.remove(uuid);
		if (symbols == null) return;
		// if (swf == null) return;

		// if (SWFLite.instances.exists(instanceID) && SWFLite.instances.get(instanceID) == swf)
		// {
		// 	SWFLite.instances.remove(instanceID);
		// }

		#if (openfl > "9.1.0")
		for (className in symbolsByClassName.keys())
		{
			Assets.unregisterBinding(className, this);
		}
		#end

		for (bitmapSymbol in bitmapSymbols)
		{
			Assets.cache.removeBitmapData(bitmapSymbol.path);
		}
	}
	#end

	#if lime
	private function __copyChannel(image:Image, alpha:Image):Void
	{
		if (alpha != null)
		{
			if (!image.transparent)
			{
				#if flash
				var copy = new Image(0, 0, image.width, image.height);
				copy.copyPixels(image, image.rect, new Vector2());
				image.buffer = copy.buffer;
				#else
				image.transparent = true;
				#end
			}

			image.copyChannel(alpha, alpha.rect, new Vector2(), ImageChannel.RED, ImageChannel.ALPHA);
		}

		image.buffer.premultiplied = true;

		#if !sys
		image.premultiplied = false;
		#end
	}
	#end

	#if lime
	private override function __fromManifest(manifest:AssetManifest):Void
	{
		rootPath = manifest.rootPath;
		super.__fromManifest(manifest);

		bytesTotal = 0;

		for (id in paths.keys())
		{
			bytesTotal += sizes.get(id);
		}
	}
	#end

	#if lime
	private function __load():Future<lime.utils.AssetLibrary>
	{
		return super.load();
	}
	#end

	#if lime
	private function __loadImage(id:String):Future<Image>
	{
		return super.loadImage(id);
	}
	#end

	private function __parseBitmap(data:Dynamic):AnimateBitmapSymbol
	{
		var symbol = new AnimateBitmapSymbol();
		symbol.id = data.id;
		symbol.className = data.className;
		symbol.alpha = data.alpha;
		symbol.path = data.path;
		symbol.smooth = data.smooth;
		return symbol;
	}

	private function __parseButton(data:Dynamic):AnimateButtonSymbol
	{
		var symbol = new AnimateButtonSymbol();
		symbol.id = data.id;
		symbol.className = data.className;
		// TODO: Should these be references?
		symbol.downState = __parseSprite(data.downState);
		symbol.hitState = __parseSprite(data.hitState);
		symbol.overState = __parseSprite(data.overState);
		symbol.upState = __parseSprite(data.upState);
		return symbol;
	}

	private function __parseDynamicText(data:Dynamic):AnimateDynamicTextSymbol
	{
		var symbol = new AnimateDynamicTextSymbol();
		symbol.id = data.id;
		symbol.align = data.align;
		symbol.border = data.border;
		symbol.color = data.color;
		symbol.fontHeight = data.fontHeight;
		symbol.fontID = data.fontID;
		symbol.fontName = data.fontName;
		symbol.html = data.html;
		symbol.indent = data.indent;
		symbol.input = data.input;
		symbol.leading = data.leading;
		symbol.leftMargin = data.leftMargin;
		symbol.multiline = data.multiline;
		symbol.password = data.password;
		symbol.rightMargin = data.rightMargin;
		symbol.selectable = data.selectable;
		symbol.text = data.text;
		symbol.wordWrap = data.wordWrap;
		symbol.x = __pixel(data.rect[0]);
		symbol.y = __pixel(data.rect[1]);
		symbol.width = __pixel(data.rect[2]);
		symbol.height = __pixel(data.rect[3]);
		return symbol;
	}

	private function __parseFilters(filters:Array<Array<Dynamic>>):Array<FilterType>
	{
		if (filters == null) return null;

		var result = [];

		for (filter in filters)
		{
			if (filter == null || filter.length == 0) continue;

			switch (filter[0])
			{
				case 0:
					result.push(FilterType.BlurFilter(filter[1], filter[2], filter[3]));

				case 1:
					result.push(FilterType.ColorMatrixFilter(filter[1]));

				case 2:
					result.push(FilterType.DropShadowFilter(filter[1], filter[2], filter[3], filter[4], filter[5], filter[6], filter[7], filter[8], filter[9],
						filter[10], filter[11]));

				case 3:
					result.push(FilterType.GlowFilter(filter[1], filter[2], filter[3], filter[4], filter[5], filter[6], filter[7], filter[8]));

				default:
			}
		}

		return result;
	}

	private function __parseFont(data:Dynamic):AnimateFontSymbol
	{
		var symbol = new AnimateFontSymbol();
		symbol.id = data.id;
		symbol.advances = data.advances;
		symbol.ascent = data.ascent;
		symbol.bold = data.bold;
		symbol.codes = data.codes;
		symbol.descent = data.descent;
		symbol.italic = data.italic;
		symbol.leading = data.leading;
		symbol.name = data.name;
		if (Reflect.hasField(data, "glyphs"))
		{
			symbol.glyphs = [];
			var glyphs:Array<Array<Dynamic>> = data.glyphs;
			for (glyphIndex in 0...glyphs.length)
			{
				var data = glyphs[glyphIndex];
				if (data != null)
				{
					var commands:Array<AnimateShapeCommand> = [];
					symbol.glyphs[glyphIndex] = commands;
					var i = 0;

					while (i < data.length)
					{
						switch (data[i])
						{
							case BEGIN_BITMAP_FILL:
								commands.push(BeginBitmapFill(data[i + 1], __parseMatrix(data[i + 2]), data[i + 3], data[i + 4]));
								i += 5;
							case BEGIN_FILL:
								commands.push(BeginFill(data[i + 1], data[i + 2]));
								i += 3;
							case BEGIN_GRADIENT_FILL:
								commands.push(BeginGradientFill(data[i + 1], data[i + 2], data[i + 3], data[i + 4], __parseMatrix(data[i + 5]), data[i + 6],
									data[i + 7], data[i + 8]));
								i += 9;
							case CLEAR_LINE_STYLE:
								commands.push(LineStyle(null, null, null, null, null, null, null, null));
								i++;
							case CURVE_TO:
								commands.push(CurveTo(__pixel(data[i + 1]), __pixel(data[i + 2]), __pixel(data[i + 3]), __pixel(data[i + 4])));
								i += 5;
							case END_FILL:
								commands.push(EndFill);
								i++;
							case LINE_STYLE:
								commands.push(LineStyle(data[i + 1], data[i + 2], data[i + 3], data[i + 4], data[i + 5], data[i + 6], data[i + 7],
									data[i + 8]));
								i += 9;
							case LINE_TO:
								commands.push(LineTo(__pixel(data[i + 1]), __pixel(data[i + 2])));
								i += 3;
							case MOVE_TO:
								commands.push(MoveTo(__pixel(data[i + 1]), __pixel(data[i + 2])));
								i += 3;
							default:
								i++;
						}
					}
				}
			}
		}
		return symbol;
	}

	private function __parseMatrix(values:Array<Float>):Matrix
	{
		return values != null ? new Matrix(values[0], values[1], values[2], values[3], __pixel(cast values[4]), __pixel(cast values[5])) : null;
	}

	private function __parseShape(data:Dynamic):AnimateShapeSymbol
	{
		var symbol = new AnimateShapeSymbol();
		symbol.id = data.id;
		symbol.commands = [];

		var data:Array<Dynamic> = data.commands;
		var commands = symbol.commands;
		var i = 0;

		while (i < data.length)
		{
			switch (data[i])
			{
				case BEGIN_BITMAP_FILL:
					commands.push(BeginBitmapFill(data[i + 1], __parseMatrix(data[i + 2]), data[i + 3], data[i + 4]));
					i += 5;
				case BEGIN_FILL:
					commands.push(BeginFill(data[i + 1], data[i + 2]));
					i += 3;
				case BEGIN_GRADIENT_FILL:
					commands.push(BeginGradientFill(data[i + 1], data[i + 2], data[i + 3], data[i + 4], __parseMatrix(data[i + 5]), data[i + 6], data[i + 7],
						data[i + 8]));
					i += 9;
				case CLEAR_LINE_STYLE:
					commands.push(LineStyle(null, null, null, null, null, null, null, null));
					i++;
				case CURVE_TO:
					commands.push(CurveTo(__pixel(data[i + 1]), __pixel(data[i + 2]), __pixel(data[i + 3]), __pixel(data[i + 4])));
					i += 5;
				case END_FILL:
					commands.push(EndFill);
					i++;
				case LINE_STYLE:
					commands.push(LineStyle(data[i + 1], data[i + 2], data[i + 3], data[i + 4], data[i + 5], data[i + 6], data[i + 7], data[i + 8]));
					i += 9;
				case LINE_TO:
					commands.push(LineTo(__pixel(data[i + 1]), __pixel(data[i + 2])));
					i += 3;
				case MOVE_TO:
					commands.push(MoveTo(__pixel(data[i + 1]), __pixel(data[i + 2])));
					i += 3;
				default:
					i++;
			}
		}
		return symbol;
	}

	private function __parseMorphShape(data:Dynamic):AnimateMorphShapeSymbol
	{
		var symbol = new AnimateMorphShapeSymbol();
		symbol.id = data.id;
		symbol.commands = [];

		var startData:Array<Dynamic> = data.startCommands;
		var endData:Array<Dynamic> = data.endCommands;
		var commands = symbol.commands;
		var i = 0;

		while (i < startData.length)
		{
			switch (startData[i])
			{
				case BEGIN_BITMAP_FILL:
					commands.push(BeginBitmapFill(startData[i + 1],
                                                  __parseMatrix(startData[i + 2]), __parseMatrix(endData[i + 2]),
                                                  startData[i + 3], startData[i + 4]));
					i += 5;
				case BEGIN_FILL:
					commands.push(BeginFill(startData[i + 1], endData[i + 1],
                                            startData[i + 2], endData[i + 2]));
					i += 3;
				case BEGIN_GRADIENT_FILL:
					commands.push(BeginGradientFill(startData[i + 1],
                                                    startData[i + 2], endData[i + 2],
                                                    startData[i + 3], endData[i + 3],
                                                    startData[i + 4], endData[i + 4],
                                                    __parseMatrix(startData[i + 5]), __parseMatrix(endData[i + 5]),
                                                    startData[i + 6],
                                                    startData[i + 7],
						startData[i + 8]));
					i += 9;
				case CLEAR_LINE_STYLE:
					commands.push(LineStyle(null, null, null, null, null, null, null, null, null, null, null));
					i++;
				case CURVE_TO:
					commands.push(CurveTo(__pixel(startData[i + 1]), __pixel(startData[i + 2]), __pixel(startData[i + 3]), __pixel(startData[i + 4]),
                                          __pixel(endData[i + 1]), __pixel(endData[i + 2]), __pixel(endData[i + 3]), __pixel(endData[i + 4])));
                    i += 5;
                case END_FILL:
                    commands.push(EndFill);
                    i++;
                case LINE_STYLE:
					commands.push(LineStyle(startData[i + 1], endData[i + 1],
                                            startData[i + 2], endData[i + 2],
                                            startData[i + 3], endData[i + 3],
                                            startData[i + 4],
                                            startData[i + 5],
                                            startData[i + 6],
                                            startData[i + 7],
                                            startData[i + 8]));
					i += 9;
				case LINE_TO:
					commands.push(LineTo(__pixel(startData[i + 1]), __pixel(startData[i + 2]),
                                         __pixel(endData[i + 1]), __pixel(endData[i + 2])));
					i += 3;
				case MOVE_TO:
					commands.push(MoveTo(__pixel(startData[i + 1]), __pixel(startData[i + 2]),
                                         __pixel(endData[i + 1]), __pixel(endData[i + 2])));
					i += 3;
				default:
					i++;
			}
		}
		return symbol;
	}

	private function __parseSprite(data:Dynamic):AnimateSpriteSymbol
	{
		if (data == null) return null;

		var symbol = new AnimateSpriteSymbol();
		symbol.id = data.id;
		symbol.className = data.className;
		symbol.baseClassName = data.baseClassName;
		symbol.scale9Grid = data.scale9Grid != null ? new Rectangle(__pixel(data.scale9Grid[0]), __pixel(data.scale9Grid[1]), __pixel(data.scale9Grid[2]),
			__pixel(data.scale9Grid[3])) : null;
		var frames:Array<Dynamic> = data.frames;
		var frame:AnimateFrame,
			objects:Array<Dynamic>,
			object:AnimateFrameObject;
		for (frameData in frames)
		{
			frame = new AnimateFrame();
			if (Reflect.hasField(frameData, "label"))
			{
				frame.labels = [frameData.label];
			}
			else if (Reflect.hasField(frameData, "labels"))
			{
				frame.labels = frameData.labels;
			}
			// frame.script = frameData.script;
			if (Reflect.hasField(frameData, "scriptSource"))
			{
				frame.scriptSource = frameData.scriptSource;
			}
			objects = frameData.objects;
			if (objects != null && objects.length > 0)
			{
				frame.objects = [];
				for (objectData in objects)
				{
					object = new AnimateFrameObject();
					object.blendMode = objectData.blendMode;
					object.cacheAsBitmap = objectData.cacheAsBitmap;
					object.clipDepth = objectData.clipDepth;
					object.colorTransform = objectData.colorTransform != null ? new ColorTransform(__pixel(objectData.colorTransform[0]),
						__pixel(objectData.colorTransform[1]), __pixel(objectData.colorTransform[2]), __pixel(objectData.colorTransform[3]),
						__pixel(objectData.colorTransform[4]), __pixel(objectData.colorTransform[5]), __pixel(objectData.colorTransform[6]),
						__pixel(objectData.colorTransform[7])) : null;
					object.depth = objectData.depth;
					object.filters = __parseFilters(objectData.filters);
					object.id = objectData.id;
					object.matrix = __parseMatrix(objectData.matrix);
					object.name = objectData.name;
					object.symbol = objectData.symbol;
					object.type = objectData.type;
					object.visible = objectData.visible;
                    object.ratio = objectData.ratio;
					frame.objects.push(object);
				}
			}
			symbol.frames.push(frame);
		}
		return symbol;
	}

	private function __parseStaticText(data:Dynamic):AnimateStaticTextSymbol
	{
		var symbol = new AnimateStaticTextSymbol();
		symbol.id = data.id;
		symbol.matrix = __parseMatrix(data.matrix);
		symbol.records = data.records;
		return symbol;
	}

	private inline function __pixel(value:Int):Float
	{
		return value / 20;
	}
}

@:enum abstract SWFShapeCommandType(Int) from Int to Int
{
	public var BEGIN_BITMAP_FILL = 0;
	public var BEGIN_FILL = 1;
	public var BEGIN_GRADIENT_FILL = 2;
	public var CLEAR_LINE_STYLE = 3;
	public var CURVE_TO = 4;
	public var END_FILL = 5;
	public var LINE_STYLE = 6;
	public var LINE_TO = 7;
	public var MOVE_TO = 8;
}

@:enum abstract SWFSymbolType(Int) from Int to Int
{
	public var BITMAP = 0;
	public var BUTTON = 1;
	public var DYNAMIC_TEXT = 2;
	public var FONT = 3;
	public var SHAPE = 4;
	public var SPRITE = 5;
	public var STATIC_TEXT = 6;
	public var MORPH_SHAPE = 7;
}
