package format.swf.lite;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.PixelSnapping;
import flash.display.Shape;
import flash.events.Event;
import flash.filters.*;
import flash.Lib;
import format.swf.lite.symbols.BitmapSymbol;
import format.swf.lite.symbols.DynamicTextSymbol;
import format.swf.lite.symbols.ShapeSymbol;
import format.swf.lite.symbols.SpriteSymbol;
import format.swf.lite.symbols.StaticTextSymbol;
import format.swf.lite.timeline.FrameObject;
import format.swf.lite.SWFLite;

#if openfl
import openfl.Assets;
#end


class MovieClip extends flash.display.MovieClip {
	
	
	@:noCompletion private static var clips:Array <MovieClip>;
	@:noCompletion private static var initialized:Bool;
	
	@:noCompletion private var lastUpdate:Int;
	@:noCompletion private var playing:Bool;
	@:noCompletion private var swf:SWFLite;
	@:noCompletion private var symbol:SpriteSymbol;
	
	#if flash
	@:noCompletion private var __currentFrame:Int;
	@:noCompletion private var __totalFrames:Int;
	#end
	
	
	public function new (swf:SWFLite, symbol:SpriteSymbol) {
		
		super ();
		
		this.swf = swf;
		this.symbol = symbol;
		
		if (!initialized) {
			
			clips = new Array <MovieClip> ();
			initialized = true;
			
		}
		
		__currentFrame = 1;
		__totalFrames = symbol.frames.length;
		
		update ();
		
		if (__totalFrames > 1) {
			
			Lib.current.stage.addEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
			play ();
			
		}
		
	}
	
	
	@:noCompletion private inline function applyTween (start:Float, end:Float, ratio:Float):Float {
		
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
	
	
	//private function createDynamicText (symbol:TagDefineEditText):TextField {
		//
		//var textField = new TextField ();
		//textField.selectable = !symbol.noSelect;
		//
		//return textField;
		//
	//}
	
	
	@:noCompletion private function createShape (symbol:ShapeSymbol):Shape {
		
		var shape = new Shape ();
		var graphics = shape.graphics;
		
		for (command in symbol.commands) {
			
			switch (command) {
				
				case BeginFill (color, alpha):
					
					graphics.beginFill (color, alpha);
				
				case BeginBitmapFill (bitmapID, matrix, repeat, smooth):
					
					#if openfl
					
					var bitmap:BitmapSymbol = cast swf.symbols.get (bitmapID);
					
					if (bitmap != null && bitmap.path != "") {
						
						var bitmapData = Assets.getBitmapData (bitmap.path);
						graphics.beginBitmapFill (bitmapData, matrix, repeat, smooth);
						
					}
					
					#end
				
				case BeginGradientFill (fillType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio):
					
					#if (cpp || neko)
					shape.cacheAsBitmap = true;
					#end
					graphics.beginGradientFill (fillType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
				
				case CurveTo (controlX, controlY, anchorX, anchorY):
					
					#if (cpp || neko)
					shape.cacheAsBitmap = true;
					#end
					graphics.curveTo (controlX, controlY, anchorX, anchorY);
				
				case EndFill:
					
					graphics.endFill ();
				
				case LineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):
					
					if (thickness != null) {
						
						graphics.lineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
						
					} else {
						
						graphics.lineStyle ();
						
					}
				
				case LineTo (x, y):
					
					graphics.lineTo (x, y);
				
				case MoveTo (x, y):
					
					graphics.moveTo (x, y);
				
			}
			
		}
		
		/*if (shape.cacheAsBitmap) {
			
			var bitmapData = new BitmapData (Math.ceil (shape.width), Math.ceil (shape.height), true, 0x00000000);
			bitmapData.draw (shape);
			return new Bitmap (bitmapData);
			
		}*/
		
		return shape;
		
	}
	
	
	//private function createStaticText (symbol:TagDefineText):TextField {
		//
		//var textField = new TextField ();
		//textField.selectable = false;
		//textField.x += instance.left;
		//
		// xfl does not embed the font
		//textField.embedFonts = true;
		//
		//var format = new TextFormat ();
		//
		///*
		//for (record in symbol.records) {
			//
			//var pos = textField.text.length;
			//
			//for (entry in record.glyphEntries) {
				//
				//entry.
				//
			//}
			//
			//textField.appendText (record.);
			//
			//if (textRun.textAttrs.face != null) format.font = textRun.textAttrs.face;
			//if (textRun.textAttrs.alignment != null) format.align = Reflect.field (TextFormatAlign, textRun.textAttrs.alignment.toUpperCase ());
			//if (textRun.textAttrs.size != 0) format.size = textRun.textAttrs.size;
			//if (textRun.textAttrs.fillColor != 0) {
				//
				//if (textRun.textAttrs.alpha != 0) {
					//
					// need to add alpha to color
					//format.color = textRun.textAttrs.fillColor;
					//
				//} else {
					//
					//format.color = textRun.textAttrs.fillColor;
					//
				//}
				//
			//}
			//
			//textField.setTextFormat (format, pos, textField.text.length);
			//
		//}*/
		//
		//return textField;
		//
	//}
	
	
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
	
	
	@:noCompletion private function enterFrame ():Void {
		
		if (lastUpdate == __currentFrame) {
			
			__currentFrame ++;
			
			if (__currentFrame > __totalFrames) {
				
				__currentFrame = 1;
				
			}
			
		}
		
		update ();
		
	}
	
	
	/*public override function flatten ():Void {
		
		var bounds = getBounds (this);
		var bitmapData = null;
		
		if (bounds.width > 0 && bounds.height > 0) {
			
			bitmapData = new BitmapData (Std.int (bounds.width), Std.int (bounds.height), true, #if neko { a: 0, rgb: 0x000000 } #else 0x00000000 #end);
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
			
			var bitmap = new Bitmap (bitmapData);
			bitmap.smoothing = true;
			bitmap.x = bounds.left;
			bitmap.y = bounds.top;
			addChild (bitmap);
			
		}
		
	}*/
	
	
	@:noCompletion private function getFrame (frame:Dynamic):Int {
		
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
	
	
	@:noCompletion private function placeObject (displayObject:DisplayObject, frameObject:FrameObject):Void {
		
		if (frameObject.name != null) {
			
			displayObject.name = frameObject.name;
			
		}
		
		if (frameObject.matrix != null) {
			
			displayObject.transform.matrix = frameObject.matrix;
			
			if (Std.is (displayObject, DynamicTextField)) {
				
				displayObject.x += untyped displayObject.symbol.x;
				displayObject.y += untyped displayObject.symbol.y;
				
			}
			
		}
		
		if (frameObject.colorTransform != null) {
			
			displayObject.transform.colorTransform = frameObject.colorTransform;
			
		}
		
		if (frameObject.filters != null) {
			
			var filters:Array<BitmapFilter> = [];
			
			for (filter in frameObject.filters) {
				
				switch (filter) {
					
					case BlurFilter (blurX, blurY, quality):
						
						filters.push (new BlurFilter (blurX, blurY, quality));
					
					case ColorMatrixFilter (matrix):
						
						filters.push (new ColorMatrixFilter (matrix));
					
					case DropShadowFilter (distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject):
						
						filters.push (new DropShadowFilter (distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject));
					
					case GlowFilter (color, alpha, blurX, blurY, strength, quality, inner, knockout):
						
						filters.push (new GlowFilter (color, alpha, blurX, blurY, strength, quality, inner, knockout));
					
				}
				
			}
			
			displayObject.filters = filters;
			
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
	
	
	@:noCompletion private function renderFrame (index:Int):Void {
		
		var frame = symbol.frames[index];
		
		//if (frame.frameNumber == __currentFrame - 1 || frame.tweenType == null || frame.tweenType == "") {
		
		var mask = null;
		var maskObject = null;
		
		for (object in frame.objects) {
			
			if (swf.symbols.exists (object.id)) {
				
				var symbol = swf.symbols.get (object.id);
				var displayObject:DisplayObject = null;
				
				if (Std.is (symbol, SpriteSymbol)) {
					
					displayObject = new MovieClip (swf, cast symbol);
					
				} else if (Std.is (symbol, ShapeSymbol)) {
					
					displayObject = createShape (cast symbol);
					
				} else if (Std.is (symbol, BitmapSymbol)) {
					
					displayObject = new Bitmap (Assets.getBitmapData (cast (symbol, BitmapSymbol).path), PixelSnapping.AUTO, true);
					
				} else if (Std.is (symbol, DynamicTextSymbol)) {
					
					displayObject = new DynamicTextField (swf, cast symbol);
					
				} else if (Std.is (symbol, StaticTextSymbol)) {
					
					//
					
				}
				
				if (displayObject != null) {
					
					placeObject (displayObject, object);
					
					if (mask != null) {
						
						if (mask.clipDepth < object.depth) {
							
							mask = null;
							
						} else {
							
							displayObject.mask = maskObject;
							
						}
						
					} else {
						
						displayObject.mask = null;
						
					}
					
					if (object.clipDepth != 0 #if neko && object.clipDepth != null #end) {
						
						mask = object;
						displayObject.visible = false;
						maskObject = displayObject;
						
					}
					
					addChild (displayObject);
					
				}
				
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
					var ratio = (__currentFrame - frame.index) / frame.duration;
					
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
	
	
	public function unflatten ():Void {
		
		lastUpdate = -1;
		update ();
		
	}
	
	
	@:noCompletion private function update ():Void {
		
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
				//if (data.frames[i]. <= __currentFrame) {
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
	@:noCompletion @:getter public function get_currentFrame():Int {
		
		return __currentFrame;
		
	}
	
	
	@:noCompletion @:getter public function get___totalFrames():Int {
		
		return __totalFrames;
		
	}
	#end
	
	
	
	
	// Event Handlers
	
	
	
	
	@:noCompletion private static function stage_onEnterFrame (event:Event):Void {
		
		for (clip in clips) {
			
			clip.enterFrame ();
			
		}
		
	}
	
	
}