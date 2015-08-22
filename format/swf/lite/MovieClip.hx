package format.swf.lite;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.PixelSnapping;
import flash.display.Shape;
import flash.events.Event;
import flash.filters.*;
import flash.Lib;
import format.swf.lite.symbols.BitmapSymbol;
import format.swf.lite.symbols.ButtonSymbol;
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
			
			initialized = true;
			
		}
		
		__currentFrame = 1;
		__totalFrames = symbol.frames.length;
		
		update ();
		
		//if (__totalFrames > 1) {
			//
			//#if flash
			//Lib.current.stage.addEventListener (Event.ENTER_FRAME, stage_onEnterFrame, false, 0, true);
			//play ();
			//#elseif (openfl && !openfl_legacy)
			//play ();
			//#end
			//
		//}
		
	}
	
	
	@:noCompletion private inline function applyTween (start:Float, end:Float, ratio:Float):Float {
		
		return start + ((end - start) * ratio);
		
	}
	
	
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
		
		return shape;
		
	}
	
	
	@:noCompletion private function enterFrame ():Void {
		
		if (playing) {
			
			if (lastUpdate == __currentFrame) {
				
				__currentFrame ++;
				
				if (__currentFrame > __totalFrames) {
					
					__currentFrame = 1;
					
				}
				
			}
			
			update ();
			
		}
		
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
			
			var index:Int = cast frame;
			
			if (index < 1) return 1;
			if (index > __totalFrames) return __totalFrames;
			
			return index;
			
		} else if (Std.is (frame, String)) {
			
			var label:String = cast frame;
			
			for (i in 0...symbol.frames.length) {
				
				if (symbol.frames[i].label == label) {
					
					return i;
					
				}
				
			}
			
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
				displayObject.y += untyped displayObject.symbol.y #if flash + 4 #end;
				
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
		
		Reflect.setField (this, displayObject.name, displayObject);
		
	}
	
	
	public override function play ():Void {
		
		if (!playing && __totalFrames > 1) {
			
			playing = true;
			
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
					
					displayObject = new StaticTextField (swf, cast symbol);
					
				} else if (Std.is (symbol, ButtonSymbol)) {
					
					displayObject = new SimpleButton (swf, cast symbol);
					
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
		
	}
	
	
	public override function stop ():Void {
		
		if (playing) {
			
			playing = false;
			
		}
		
	}
	
	
	public function unflatten ():Void {
		
		lastUpdate = -1;
		update ();
		
	}
	
	
	@:noCompletion private function update ():Void {
		
		if (__currentFrame != lastUpdate) {
			
			// TODO: Optimize the frame updates to reuse objects
			
			for (i in 0...numChildren) {
				
				var child = getChildAt (0);
				
				if (Std.is (child, MovieClip)) {
					
					untyped child.stop ();
					
				}
				
				removeChildAt (0);
				
			}
			
			var frameIndex = __currentFrame - 1;
			
			if (frameIndex > -1) {
				
				renderFrame (frameIndex);
				
			}
			
			#if (!flash && openfl && !openfl_legacy)
			__renderDirty = true;
			DisplayObject.__worldRenderDirty++;
			#end
			
		}
		
		lastUpdate = __currentFrame;
		
	}
	
	
	#if (!flash && openfl && !openfl_legacy)
	public override function __enterFrame ():Void {
		
		enterFrame ();
		
		super.__enterFrame ();
		
	}
	#end
	
	
	
	
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
	
	
	
	
	#if flash
	@:noCompletion private function stage_onEnterFrame (event:Event):Void {
		
		enterFrame ();
		
	}
	#end
	
	
}