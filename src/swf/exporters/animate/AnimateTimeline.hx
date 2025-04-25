package swf.exporters.animate;

import lime.utils.Log;
import openfl.display.DisplayObject;
import openfl.display.FrameLabel;
import openfl.display.FrameScript;
import openfl.display.MovieClip;
import openfl.display.Scene;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.display.Timeline;
// import openfl.events.Event;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ConvolutionFilter;
import openfl.filters.DisplacementMapFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import openfl.geom.ColorTransform;
#if hscript
import hscript.Interp;
import hscript.Parser;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(swf.exporters.animate.AnimateLibrary)
@:access(swf.exporters.animate.AnimateSymbol)
@:access(openfl.display.DisplayObject)
@:access(openfl.display.MovieClip)
@:access(openfl.geom.ColorTransform)
class AnimateTimeline extends Timeline
{
	#if 0
	// Suppress checkstyle warning
	private static var __unusedImport:Array<Class<Dynamic>> = [
		AnimateBitmapSymbol,
		AnimateButtonSymbol,
		AnimateDynamicTextSymbol,
		AnimateFontSymbol,
		AnimateShapeSymbol,
		AnimateSpriteSymbol,
		AnimateStaticTextSymbol,
		AnimateSymbol,
		BlurFilter,
		ColorMatrixFilter,
		ConvolutionFilter,
		DisplacementMapFilter,
		DropShadowFilter,
		GlowFilter
	];
	#end

	@:noCompletion private var __activeInstances:Array<FrameSymbolInstance>;
	@:noCompletion private var __activeInstancesByFrameObjectID:Map<Int, FrameSymbolInstance>;
	@:noCompletion private var __currentInstancesByFrameObjectID:Map<Int, FrameSymbolInstance>;
	@:noCompletion private var __instanceFields:Array<String>;
	@:noCompletion private var __lastUpdated:Map<DisplayObject, AnimateFrameObject>;
	@:noCompletion private var __library:AnimateLibrary;
	@:noCompletion private var __previousFrame:Int;
	@:noCompletion private var __sprite:Sprite;
	@:noCompletion private var __symbol:AnimateSpriteSymbol;

	public function new(library:AnimateLibrary, symbol:AnimateSpriteSymbol)
	{
		super();

		__library = library;
		__symbol = symbol;

		frameRate = library.frameRate;
		var labels = [];
		scripts = [];

		var frame:Int;
		var frameData:AnimateFrame;

		#if hscript
		var parser:Parser = null;
		#end

		for (i in 0...__symbol.frames.length)
		{
			frame = i + 1;
			frameData = __symbol.frames[i];

			if (frameData.labels != null)
			{
				for (label in frameData.labels)
				{
					labels.push(new FrameLabel(label, frame));
				}
			}

			if (frameData.script != null)
			{
				scripts.push(new FrameScript(frameData.script, frame));
			}
			else if (frameData.scriptSource != null)
			{
				try
				{
					#if hscript
					if (parser == null)
					{
						parser = new Parser();
						parser.allowTypes = true;
					}

					var script = __createScriptCallback(parser, frameData.scriptSource);
					scripts.push(new FrameScript(script, frame));
					#elseif js
					var script = __createScriptCallback(frameData.scriptSource);
					scripts.push(new FrameScript(script, frame));
					#end
				}
				catch (e:Dynamic)
				{
					if (__symbol.className != null)
					{
						Log.warn("Unable to evaluate frame script source for symbol \"" + __symbol.className + "\" frame " + frame + "\n"
							+ frameData.scriptSource);
					}
					else
					{
						Log.warn("Unable to evaluate frame script source:\n" + frameData.scriptSource);
					}
				}
			}
		}

		scenes = [new Scene("", labels, __symbol.frames.length)];
	}

	public override function attachMovieClip(movieClip:MovieClip):Void
	{
		init(movieClip);
	}

	public override function enterFrame(currentFrame:Int):Void
	{
		if (__symbol != null && currentFrame != __previousFrame)
		{
			var frame:Int;
			var frameData:AnimateFrame;
			var instance:FrameSymbolInstance;

			var updateFrameStart = __previousFrame < currentFrame ? (__previousFrame == -1 ? 0 : __previousFrame) : 0;
			var skipFrame = false;

			// TODO: A lot more optimizing!
			if (currentFrame == 1 && __previousFrame > currentFrame && __symbol.frames[0].objects != null)
			{
				// Do nothing (on looping) if this clip has only one frame
				skipFrame = true;
				for (i in 1...__symbol.frames.length)
				{
					if (__symbol.frames[i].objects != null)
					{
						skipFrame = false;
						break;
					}
				}
			}

			if (!skipFrame)
			{
				// Reset frame objects if starting over.
				if (updateFrameStart <= 0)
				{
					__currentInstancesByFrameObjectID = new Map();
				}

				for (i in updateFrameStart...currentFrame)
				{
					frame = i + 1;
					frameData = __symbol.frames[i];

					if (frameData.objects == null) continue;

					for (frameObject in frameData.objects)
					{
						instance = __activeInstancesByFrameObjectID.get(frameObject.id);

						if (instance != null)
						{
							switch (frameObject.type)
							{
								case CREATE:
									__currentInstancesByFrameObjectID.set(frameObject.id, instance);
									__updateDisplayObject(instance.displayObject, frameObject, true);

								case UPDATE:
									__updateDisplayObject(instance.displayObject, frameObject);

								case DESTROY:
									__currentInstancesByFrameObjectID.remove(frameObject.id);
							}
						}
					}
				}

				// TODO: Less garbage?

				var currentInstances = new Array<FrameSymbolInstance>();
				var currentMasks = new Array<FrameSymbolInstance>();

				for (instance in __currentInstancesByFrameObjectID)
				{
					if (currentInstances.indexOf(instance) == -1)
					{
						currentInstances.push(instance);

						if (instance.clipDepth > 0)
						{
							currentMasks.push(instance);
						}
					}
				}

				currentInstances.sort(__sortDepths);

				var existingChild:DisplayObject;
				var targetDepth:Int;
				var targetChild:DisplayObject;
				var child:DisplayObject;
				var maskApplied:Bool;

				for (i in 0...currentInstances.length)
				{
					existingChild = (i < __sprite.numChildren) ? __sprite.getChildAt(i) : null;
					instance = currentInstances[i];

					targetDepth = instance.depth;
					targetChild = instance.displayObject;

					if (existingChild != targetChild)
					{
						__sprite.addChildAt(targetChild, i);
					}

					child = targetChild;
					maskApplied = false;

					for (mask in currentMasks)
					{
						if (targetDepth > mask.depth && targetDepth <= mask.clipDepth)
						{
							child.mask = mask.displayObject;
							maskApplied = true;
							break;
						}
					}

					if (currentMasks.length > 0 && !maskApplied && child.mask != null)
					{
						child.mask = null;
					}
				}

				// TODO: How to tell if shapes are for a scale9Grid clip?
				if (__sprite.scale9Grid != null)
				{
					__sprite.graphics.clear();
					if (currentInstances.length > 0)
					{
						var displayObject = currentInstances[0].displayObject;
						if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (displayObject, Shape))
						{
							var shape:Shape = cast displayObject;
							__sprite.graphics.copyFrom(shape.graphics);
						}
					}
				}
				else
				{
					var child;
					var i = currentInstances.length;
					var length = __sprite.numChildren;

					while (i < length)
					{
						child = __sprite.getChildAt(i);

						// TODO: Faster method of determining if this was automatically added?

						for (instance in __activeInstances)
						{
							if (instance.displayObject == child)
							{
								// set MovieClips back to initial state (autoplay)
								if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (child, MovieClip))
								{
									var movie:MovieClip = cast child;
									movie.gotoAndPlay(1);
								}

								__sprite.removeChild(child);
								i--;
								length--;
							}
						}

						i++;
					}
				}

				#if !openfljs
				__updateInstanceFields();
				#end
			}

			__previousFrame = currentFrame;
		}
	}

	private function init(sprite:Sprite):Void
	{
		if (__activeInstances != null) return;

		__sprite = sprite;

		__instanceFields = [];
		__previousFrame = -1;

		__activeInstances = [];
		__activeInstancesByFrameObjectID = new Map();
		__currentInstancesByFrameObjectID = new Map();
		__lastUpdated = new Map();

		var frame:Int;
		var frameData:AnimateFrame;
		var instance:FrameSymbolInstance;
		var duplicate:Bool;
		var symbol:AnimateSymbol;
		var displayObject:DisplayObject;

		// TODO: Create later?

		for (i in 0...scenes[0].numFrames)
		{
			frame = i + 1;
			frameData = __symbol.frames[i];

			if (frameData.objects == null) continue;

			for (frameObject in frameData.objects)
			{
				if (frameObject.type == AnimateFrameObjectType.CREATE)
				{
					if (__activeInstancesByFrameObjectID.exists(frameObject.id))
					{
						continue;
					}
					else
					{
						instance = null;
						duplicate = false;

						for (activeInstance in __activeInstances)
						{
							if (activeInstance.displayObject != null
								&& activeInstance.characterID == frameObject.symbol
								&& activeInstance.depth == frameObject.depth)
							{
								// TODO: Fix duplicates in exporter
								instance = activeInstance;
								duplicate = true;
								break;
							}
						}
					}

					if (instance == null)
					{
						symbol = __library.symbols.get(frameObject.symbol);

						if (symbol != null)
						{
							displayObject = symbol.__createObject(__library);

							if (displayObject != null)
							{
								#if !flash
								// displayObject.parent = __sprite;
								// displayObject.stage = __sprite.stage;

								// if (__sprite.stage != null) displayObject.dispatchEvent(new Event(Event.ADDED_TO_STAGE, false, false));
								#end

								instance = new FrameSymbolInstance(frame, frameObject.id, frameObject.symbol, frameObject.depth, displayObject,
									frameObject.clipDepth);
							}
						}
					}

					if (instance != null)
					{
						__activeInstancesByFrameObjectID.set(frameObject.id, instance);

						if (!duplicate)
						{
							__activeInstances.push(instance);
							__updateDisplayObject(instance.displayObject, frameObject);
						}
					}
				}
			}
		}

		#if !openfljs
		__instanceFields = Type.getInstanceFields(Type.getClass(__sprite));
		#end

		enterFrame(1);
	}

	public override function initializeSprite(sprite:Sprite):Void
	{
		if (__activeInstances != null) return;

		init(sprite);

		__activeInstances = null;
		__activeInstancesByFrameObjectID = null;
		__currentInstancesByFrameObjectID = null;
		__instanceFields = null;
		__lastUpdated = null;
		__sprite = null;
		__previousFrame = -1;
	}

	@:noCompletion private function __sortDepths(a:FrameSymbolInstance, b:FrameSymbolInstance):Int
	{
		return a.depth - b.depth;
	}

	@:noCompletion private function __updateDisplayObject(displayObject:DisplayObject, frameObject:AnimateFrameObject, reset:Bool = false):Void
	{
		if (displayObject == null) return;
		if (__lastUpdated.get(displayObject) == frameObject) return;

		if (frameObject.name != null)
		{
			displayObject.name = frameObject.name;
		}

		if (frameObject.matrix != null)
		{
			displayObject.transform.matrix = frameObject.matrix;
		}

		if (frameObject.colorTransform != null)
		{
			displayObject.transform.colorTransform = frameObject.colorTransform;
		}
		else if (reset #if !flash && !displayObject.transform.colorTransform.__isDefault(false) #end)
		{
			displayObject.transform.colorTransform = new ColorTransform();
		}

		displayObject.transform = displayObject.transform;

		if (frameObject.filters != null)
		{
			var filters:Array<BitmapFilter> = [];

			for (filter in frameObject.filters)
			{
				switch (filter)
				{
					case BlurFilter(blurX, blurY, quality):
						filters.push(new BlurFilter(blurX, blurY, quality));

					case ColorMatrixFilter(matrix):
						filters.push(new ColorMatrixFilter(matrix));

					case DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject):
						filters.push(new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject));

					case GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout):
						filters.push(new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout));
				}
			}

			displayObject.filters = filters;
		}
		else
		{
			displayObject.filters = null;
		}

		if (frameObject.visible != null)
		{
			displayObject.visible = frameObject.visible;
		}

		if (frameObject.blendMode != null)
		{
			displayObject.blendMode = frameObject.blendMode;
		}

		if (frameObject.cacheAsBitmap != null)
		{
			displayObject.cacheAsBitmap = frameObject.cacheAsBitmap;
		}

		#if openfljs
		Reflect.setField(__sprite, displayObject.name, displayObject);
		#end

		__lastUpdated.set(displayObject, frameObject);
	}

	@:noCompletion private function __updateInstanceFields():Void
	{
		for (field in __instanceFields)
		{
			var length = __sprite.numChildren;
			for (i in 0...length)
			{
				var child = __sprite.getChildAt(i);
				if (child.name == field)
				{
					Reflect.setField(__sprite, field, child);
					break;
				}
			}
		}
	}

	#if hscript
	@:noCompletion private function __createScriptCallback(parser:Parser, scriptSource:String):MovieClip->Void
	{
		var program = parser.parseString(scriptSource);
		var interp = new Interp();

		return function(scope:MovieClip):Void
		{
			interp.variables.set("this", scope);
			interp.execute(program);
		};
	}
	#end

	#if js
	@:noCompletion private function __createScriptCallback(scriptSource:String):MovieClip->Void
	{
		var script = untyped untyped #if haxe4 js.Syntax.code #else __js__ #end ("eval({0})", "(function(){" + scriptSource + "})");
		return function(scope:MovieClip):Void
		{
			try
			{
				script.call(scope);
			}
			catch (e:Dynamic)
			{
				Log.info("Error evaluating frame script\n "
					+ e
					+ "\n"
					+ haxe.CallStack.exceptionStack().map(function(a)
					{
						return untyped a[2];
					}).join("\n")
					+ "\n"
					+ e.stack
					+ "\n"
					+ untyped script.toString());
			}
		};
	}
	#end
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
private class FrameSymbolInstance
{
	public var characterID:Int;
	public var clipDepth:Int;
	public var depth:Int;
	public var displayObject:DisplayObject;
	public var initFrame:Int;
	public var initFrameObjectID:Int; // TODO: Multiple frame object IDs may refer to the same instance

	public function new(initFrame:Int, initFrameObjectID:Int, characterID:Int, depth:Int, displayObject:DisplayObject, clipDepth:Int)
	{
		this.initFrame = initFrame;
		this.initFrameObjectID = initFrameObjectID;
		this.characterID = characterID;
		this.depth = depth;
		this.displayObject = displayObject;
		this.clipDepth = clipDepth;
	}
}
