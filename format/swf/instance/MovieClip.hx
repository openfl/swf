package format.swf.instance;


import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.events.Event;
import flash.Lib;
import format.swf.exporters.AS3GraphicsDataShapeExporter;
import format.swf.exporters.ShapeCommandExporter;
import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsLossless;
import format.swf.tags.TagDefineEditText;
import format.swf.tags.TagDefineFont;
import format.swf.tags.TagDefineShape;
import format.swf.tags.TagDefineSprite;
import format.swf.tags.TagDefineText;
import format.swf.tags.TagPlaceObject;
import format.swf.timeline.FrameObject;


class MovieClip extends flash.display.MovieClip {
	
	
	private static var clips:Array <MovieClip>;
	private static var initialized:Bool;
	
	private var data:SWFTimelineContainer;
	private var lastUpdate:Int;
	private var playing:Bool;
	
	#if flash
	private var __currentFrame:Int;
	private var __totalFrames:Int;
	#end
	
	
	
	public function new (data:SWFTimelineContainer) {
		
		super ();
		
		this.data = data;
		
		if (!initialized) {
			
			clips = new Array <MovieClip> ();
			Lib.current.stage.addEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
			
			initialized = true;
			
		}
		
		//currentFrame = 1;
		__currentFrame = 1;
		//__totalFrames = data.frames.length;
		__totalFrames = data.frames.length;
		
		update ();
		
		if (__totalFrames > 1) {
			
			//play ();
			
		}
		
	}
	
	
	private inline function applyTween (start:Float, end:Float, ratio:Float):Float {
		
		return start + ((end - start) * ratio);
		
	}
	
	
	/*private function createBitmap (xfl:XFL, instance:DOMBitmapInstance):Bitmap {
		
		var bitmap = null;
		var bitmapData = null;
		
		if (xfl.document.media.exists (instance.libraryItemName)) {
			
			var bitmapItem = xfl.document.media.get (instance.libraryItemName);
			bitmapData = Assets.getBitmapData (Path.directory (xfl.path) + "/bin/" + bitmapItem.bitmapDataHRef);
			
		}
		
		if (bitmapData != null) {
			
			bitmap = new Bitmap (bitmapData);
			
			if (instance.matrix != null) {
				
				bitmap.transform.matrix = instance.matrix;
				
			}
			
		}
		
		return bitmap;
		
	}*/
	
	
	private function createDynamicText (symbol:TagDefineEditText):TextField {
		
		var textField = new TextField ();
		textField.selectable = !symbol.noSelect;
		
		var rect:Rectangle = symbol.bounds.rect;
		
		textField.width = rect.width;
		textField.height = rect.height;
		textField.multiline = symbol.multiline;
		textField.wordWrap = symbol.wordWrap;
		textField.autoSize = (symbol.autoSize)? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
		textField.border = symbol.border;
		
		return textField;
		
	}
	
	
	private function createShape (symbol:TagDefineShape):Shape {
		
		//var handler = new AS3GraphicsDataShapeExporter (data);
		//symbol.export (handler);
		//
		//var shape = new Shape ();
		//shape.graphics.drawGraphicsData (handler.graphicsData);
		
		var handler = new ShapeCommandExporter (data);
		symbol.export (handler);
		
		var shape = new Shape ();
		
		for (command in handler.commands) {
			
			switch (command.type) {
				
				case BEGIN_FILL: shape.graphics.beginFill (command.params[0], command.params[1]);
				case BEGIN_GRADIENT_FILL: 
					
					shape.cacheAsBitmap = true;
					shape.graphics.beginGradientFill (command.params[0], command.params[1], command.params[2], command.params[3], command.params[4], command.params[5], command.params[6], command.params[7]);
				
				case BEGIN_BITMAP_FILL: 
					
					var bitmap = new Bitmap (cast data.getCharacter (command.params[0]));
					shape.graphics.beginBitmapFill (bitmap.bitmapData, command.params[1], command.params[2], command.params[3]);
					
				case END_FILL: shape.graphics.endFill ();
				case LINE_STYLE: 
					
					if (command.params.length > 0) {
						
						shape.graphics.lineStyle (command.params[0], command.params[1], command.params[2], command.params[3], command.params[4], command.params[5], command.params[6], command.params[7]);
						
					} else {
						
						shape.graphics.lineStyle ();
						
					}
				
				case MOVE_TO: shape.graphics.moveTo (command.params[0], command.params[1]);
				case LINE_TO: shape.graphics.lineTo (command.params[0], command.params[1]);
				case CURVE_TO: 
					
					shape.cacheAsBitmap = true;
					shape.graphics.curveTo (command.params[0], command.params[1], command.params[2], command.params[3]);
				
			}
			
		}
		
		return shape;
		
	}
	
	
	private function createStaticText (symbol:TagDefineText):Sprite {
		
		var shape = new Shape ();
		
		var matrix = null;
		var cacheMatrix = null;
		var tx = symbol.textMatrix.matrix.tx * 0.05;
		var ty = symbol.textMatrix.matrix.ty * 0.05;
		var color = 0;
		var alpha = 1.0;
		
		var sprite = new Sprite ();
		
		for (record in symbol.records) {
			
			var scale = (record.textHeight / 1024) * 0.05;
			
			cacheMatrix = matrix;
			matrix = symbol.textMatrix.matrix.clone ();
			matrix.scale (scale, scale);
			
			if (record.hasColor) {
				
				color = record.textColor & 0x00FFFFFF;
				alpha = (record.textColor & 0xFF) / 0xFF;
				
			}
			
			if (cacheMatrix != null && (record.hasColor || record.hasFont) && (!record.hasXOffset && !record.hasYOffset)) {
				
				matrix.tx = cacheMatrix.tx;
				matrix.ty = cacheMatrix.ty;
				
			} else {
				
				matrix.tx = tx + (record.xOffset) * 0.05;
				matrix.ty = ty + (record.yOffset) * 0.05;
				
			}
			
			for (i in 0...record.glyphEntries.length) {
				
				var handler = new ShapeCommandExporter (data);
				handler.lineStyle ();
				var shape = new Shape ();
				
				handler.beginFill (color, alpha);
				
				var font:TagDefineFont = cast data.getCharacter (record.fontId);
				font.export (handler, record.glyphEntries[i].index);
				
				handler.endFill();
				
				for (command in handler.commands) {
					
					switch (command.type) {
						
						case BEGIN_FILL: shape.graphics.beginFill (command.params[0], command.params[1]);
						case END_FILL: shape.graphics.endFill ();
						case LINE_STYLE: 
							
							if (command.params.length > 0) {
								
								shape.graphics.lineStyle (command.params[0], command.params[1], command.params[2], command.params[3], command.params[4], command.params[5], command.params[6], command.params[7]);
								
							} else {
								
								shape.graphics.lineStyle ();
								
							}
						
						case MOVE_TO: shape.graphics.moveTo (command.params[0], command.params[1]);
						case LINE_TO: shape.graphics.lineTo (command.params[0], command.params[1]);
						case CURVE_TO: 
							
							shape.cacheAsBitmap = true;
							shape.graphics.curveTo (command.params[0], command.params[1], command.params[2], command.params[3]);
							
						default:
						
					}
					
				}
				
				shape.transform.matrix = matrix;
				matrix.tx += record.glyphEntries[i].advance * 0.05;
				
				sprite.addChild (shape);
				
			}
			
		}
		
		return sprite;
		
	}
	
	
	/*private function createSprite (symbol:SWFTimelineContainer, object:FrameObject):MovieClip {
		
		var movieClip = new MovieClip (symbol, swf);
		
		if (movieClip != null) {
			
			if (object.matrix != null) {
				
				movieClip.transform.matrix = object.matrix;
				
			}
			
			/*if (instance.color != null) {
				
				movieClip.transform.colorTransform = instance.color;
				
			}*/
			
			//movieClip.cacheAsBitmap = instance.cacheAsBitmap;
			
			/*if (instance.exportAsBitmap) {
				
				movieClip.flatten ();
				
			}
			
		}
		
		return movieClip;
		
	}*/
	
	
	private function enterFrame ():Void {
		
		if (lastUpdate == __currentFrame) {
			
			__currentFrame ++;
			
			if (__currentFrame > __totalFrames) {
				
				__currentFrame = 1;
				
			}
			
		}
		
		update ();
		
	}
	
	
	public /*override*/ function flatten ():Void {
		
		var bounds = getBounds (this);
		var bitmapData = null;
		
		if (bounds.width > 0 && bounds.height > 0) {
			
			bitmapData = new BitmapData (Std.int (bounds.width), Std.int (bounds.height), true, 0x00000000);
			var matrix = new Matrix ();
			matrix.translate (-bounds.left, -bounds.top);
			bitmapData.draw (this, matrix);
			
		}
		
		for (i in 0...numChildren) {
			
			var child = getChildAt (0);
			
			if (Std.is (child, MovieClip)) {
				
				untyped child.stop ();
				
			}
			
			removeChildAt (0);
			
		}
		
		if (bounds.width > 0 && bounds.height > 0) {
			
			var bitmap = new flash.display.Bitmap (bitmapData);
			bitmap.smoothing = true;
			bitmap.x = bounds.left;
			bitmap.y = bounds.top;
			addChild (bitmap);
			
		}
		
		stop();
		
	}
	
	
	private function getFrame (frame:Dynamic):Int {
		
		if (Std.is (frame, Int)) {
			
			return cast frame;
			
		} else if (Std.is (frame, String)) {
			
			// need to handle frame labels
			
		}
		
		return 1;
		
	}
	
	
	public override function gotoAndPlay (frame:#if flash flash.utils.Object #else Dynamic #end, scene:String = null):Void {
		
		__currentFrame = getFrame (frame);
		update ();
		play ();
		
	}
	
	
	public override function gotoAndStop (frame:#if flash flash.utils.Object #else Dynamic #end, scene:String = null):Void {
		
		__currentFrame = getFrame (frame);
		update ();
		stop ();
		
	}
	
	
	public override function nextFrame ():Void {
		
		var next = __currentFrame + 1;
		
		if (next > __totalFrames) {
			
			next = __totalFrames;
			
		}
		
		gotoAndStop (next);
		
	}
	
	
	private function placeObject (displayObject:DisplayObject, frameObject:FrameObject):Void {
		
		var firstTag:TagPlaceObject = cast data.tags [frameObject.placedAtIndex];
		var lastTag:TagPlaceObject = null;
		
		if (frameObject.lastModifiedAtIndex > 0) {
			
			lastTag = cast data.tags [frameObject.lastModifiedAtIndex];
			
		}
		
		if (lastTag != null && lastTag.hasName) {
			
			displayObject.name = lastTag.instanceName;
			
		} else if (firstTag.hasName) {
			
			displayObject.name = firstTag.instanceName;
			
		}
		
		if (lastTag != null && lastTag.hasMatrix) {
			
			var matrix = lastTag.matrix.matrix;
			matrix.tx *= 1 / 20;
			matrix.ty *= 1 / 20;
			
			displayObject.transform.matrix = matrix;
			
		} else if (firstTag.hasMatrix) {
			
			var matrix = firstTag.matrix.matrix;
			matrix.tx *= 1 / 20;
			matrix.ty *= 1 / 20;
			
			displayObject.transform.matrix = matrix;
			
		}
		
		if (lastTag != null && lastTag.hasColorTransform) {
			
			displayObject.transform.colorTransform = lastTag.colorTransform.colorTransform;
			
		} else if (firstTag.hasColorTransform) {
			
			displayObject.transform.colorTransform = firstTag.colorTransform.colorTransform;
			
		}
		
		if (lastTag != null && lastTag.hasFilterList) {
			var filters_arr:Array<Dynamic> = [];
			for (i in 0...lastTag.surfaceFilterList.length) { filters_arr[i] = lastTag.surfaceFilterList[i].filter; }
			displayObject.filters = filters_arr;
		} else if ( firstTag.hasFilterList) {
			var filters_arr:Array<Dynamic> = [];
			for (i in 0...firstTag.surfaceFilterList.length) { filters_arr[i] = firstTag.surfaceFilterList[i].filter; }
			displayObject.filters = filters_arr;
		}
		
	}
	
	
	public override function play ():Void {
		
		if (!playing && __totalFrames > 1) {
			
			playing = true;
			clips.push (this);
			
		}
		
	}
	
	
	public override function prevFrame ():Void {
		
		var previous = __currentFrame - 1;
		
		if (previous < 1) {
			
			previous = 1;
			
		}
		
		gotoAndStop (previous);
		
	}
	
	
	private function renderFrame (index:Int):Void {
		
		var frame = data.frames[index];
		
		//if (frame.frameNumber == currentFrame - 1 || frame.tweenType == null || frame.tweenType == "") {
		
		for (object in frame.getObjectsSortedByDepth ()) {
			
			var symbol = data.getCharacter (object.characterId);
			var grid = data.getScalingGrid (object.characterId);
			var displayObject:DisplayObject = null;
			
			if (Std.is (symbol, TagDefineSprite)) {
				
				displayObject = new MovieClip (cast symbol);
				
			} else if (Std.is (symbol, TagDefineBitsLossless)) {
				
				displayObject = new Bitmap (cast symbol);
				
			} else if (Std.is (symbol, TagDefineBits)) {
				
				displayObject = new Bitmap (cast symbol);
				
			} else if (Std.is (symbol, TagDefineShape)) {
				
				displayObject = createShape (cast symbol);
				
			} else if (Std.is (symbol, TagDefineText)) {
				
				displayObject = createStaticText (cast symbol);
				
			} else if (Std.is (symbol, TagDefineEditText)) {
				
				displayObject = createDynamicText (cast symbol);
				
			}
			
			if (displayObject != null) {
				
				if (grid != null) {
					
					displayObject.scale9Grid = grid.splitter.rect.clone ();
					
				}
				
				placeObject (displayObject, object);
				addChild (displayObject);
				
			}
			
		}
		
			/*for (element in frame.elements) {
				
				if (Std.is (element, DOMSymbolInstance)) {
					
					var movieClip = createSymbol (xfl, cast element);
					
					if (movieClip != null) {
						
						addChild (movieClip);
						
					}
					
				} else if (Std.is (element, DOMBitmapInstance)) {
					
					var bitmap = createBitmap (xfl, cast element);
					
					if (bitmap != null) {
						
						addChild (bitmap);
						
					}
					
				} else if (Std.is (element, DOMShape)) {
					
					var shape = new Shape (cast element);
					addChild (shape);
					
				} else if (Std.is (element, DOMDynamicText)) {
					
					var text = createDynamicText (cast element);
					
					if (text != null) {
						
						addChild (text);
						
					}
					
				} else if (Std.is (element, DOMStaticText)) {
					
					var text = createStaticText (cast element);
					
					if (text != null) {
						
						addChild (text);
						
					}
					
				}
				
			}*/
			
		/*} else if (frame.tweenType == "motion") {
			
			if (index < layer.frames.length - 1) {
				
				var firstInstance = null;
				
				for (element in frame.elements) {
					
					if (Std.is (element, DOMSymbolInstance)) {
						
						firstInstance = element;
						break;
						
					}
					
				}
				
				var secondFrame = layer.frames[index + 1];
				var secondInstance = null;
				
				for (element in secondFrame.elements) {
					
					if (Std.is (element, DOMSymbolInstance)) {
						
						secondInstance = element;
						break;
						
					}
					
				}
				
				if (firstInstance.libraryItemName == secondInstance.libraryItemName) {
					
					var instance:DOMSymbolInstance = firstInstance.clone ();
					var ratio = (currentFrame - frame.index) / frame.duration;
					
					if (secondInstance.matrix != null) {
						
						if (instance.matrix == null) instance.matrix = new Matrix ();
						
						instance.matrix.a = applyTween (instance.matrix.a, secondInstance.matrix.a, ratio);
						instance.matrix.b = applyTween (instance.matrix.b, secondInstance.matrix.b, ratio);
						instance.matrix.c = applyTween (instance.matrix.c, secondInstance.matrix.c, ratio);
						instance.matrix.d = applyTween (instance.matrix.d, secondInstance.matrix.d, ratio);
						instance.matrix.tx = applyTween (instance.matrix.tx, secondInstance.matrix.tx, ratio);
						instance.matrix.ty = applyTween (instance.matrix.ty, secondInstance.matrix.ty, ratio);
						
					}
					
					if (secondInstance.color != null) {
						
						if (instance.color == null) instance.color = new Color ();
						
						instance.color.alphaMultiplier = applyTween (instance.color.alphaMultiplier, secondInstance.color.alphaMultiplier, ratio);
						instance.color.alphaOffset = applyTween (instance.color.alphaOffset, secondInstance.color.alphaOffset, ratio);
						instance.color.blueMultiplier = applyTween (instance.color.blueMultiplier, secondInstance.color.blueMultiplier, ratio);
						instance.color.blueOffset = applyTween (instance.color.blueOffset, secondInstance.color.blueOffset, ratio);
						instance.color.greenMultiplier = applyTween (instance.color.greenMultiplier, secondInstance.color.greenMultiplier, ratio);
						instance.color.greenOffset = applyTween (instance.color.greenOffset, secondInstance.color.greenOffset, ratio);
						instance.color.redMultiplier = applyTween (instance.color.redMultiplier, secondInstance.color.redMultiplier, ratio);
						instance.color.redOffset = applyTween (instance.color.redOffset, secondInstance.color.redOffset, ratio);
						
					}
					
					var movieClip = createSymbol (xfl, instance);
					
					if (movieClip != null) {
						
						addChild (movieClip);
						
					}
					
				}
				
			}
			
		} else if (frame.tweenType == "motion object") {
			
			var instances = [];
			
			for (element in frame.elements) {
				
				if (Std.is (element, DOMSymbolInstance)) {
					
					instances.push (element.clone ());
					
				}
				
			}
			
			// temporarily render without tweening
			
			for (instance in instances) {
				
				var movieClip = createSymbol (xfl, instance);
				
				if (movieClip != null) {
					
					addChild (movieClip);
					
				}
				
			}
			
		}*/
		
	}
	
	
	public override function stop ():Void {
		
		if (playing) {
			
			playing = false;
			clips.remove (this);
			
		}
		
	}
	
	
	public /*override*/ function unflatten ():Void {
		
		lastUpdate = -1;
		update ();
		
	}
	
	
	private function update ():Void {
		
		if (__currentFrame != lastUpdate) {
			
			for (i in 0...numChildren) {
				
				var child = getChildAt (0);
				
				if (Std.is (child, MovieClip)) {
					
					untyped child.stop ();
					
				}
				
				removeChildAt (0);
				
			}
			
			//var frameIndex = -1;
			//
			//for (i in 0...data.frames.length) {
				//
				//if (data.frames[i]. <= currentFrame) {
					//
					//frameIndex = i;
					//
				//}
				//
			//}
			
			var frameIndex = __currentFrame - 1;
			
			if (frameIndex > -1) {
				
				renderFrame (frameIndex);
				
			}
			
		}
		
		lastUpdate = __currentFrame;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	#if flash
	@:getter public function get_currentFrame():Int {
		
		return __currentFrame;
		
	}
	
	
	@:getter public function get___totalFrames():Int {
		
		return __totalFrames;
		
	}
	#end
	
	
	
	
	// Event Handlers
	
	
	
	
	private static function stage_onEnterFrame (event:Event):Void {
		
		for (clip in clips) {
			
			clip.enterFrame ();
			
		}
		
	}
	
	
}