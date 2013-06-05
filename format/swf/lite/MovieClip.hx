package format.swf.lite;


import flash.display.DisplayObject;
import flash.display.Shape;
import flash.events.Event;
import flash.Lib;
import format.swf.lite.symbols.BitmapSymbol;
import format.swf.lite.symbols.ShapeSymbol;
import format.swf.lite.symbols.SpriteSymbol;
import format.swf.lite.timeline.FrameObject;
import format.swf.lite.SWFLite;

#if nme
import nme.Assets;
#end


class MovieClip extends format.display.MovieClip {
	
	
	private static var clips:Array <MovieClip>;
	private static var initialized:Bool;
	
	private var lastUpdate:Int;
	private var playing:Bool;
	private var swf:SWFLite;
	private var symbol:SpriteSymbol;
	
	
	public function new (swf:SWFLite, symbol:SpriteSymbol) {
		
		super ();
		
		this.swf = swf;
		this.symbol = symbol;
		
		if (!initialized) {
			
			clips = new Array <MovieClip> ();
			Lib.current.stage.addEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
			initialized = true;
			
		}
		
		currentFrame = 1;
		totalFrames = symbol.frames.length;
		
		update ();
		
		if (totalFrames > 1) {
			
			play ();
			
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
	
	
	//private function createDynamicText (symbol:TagDefineEditText):TextField {
		//
		//var textField = new TextField ();
		//textField.selectable = !symbol.noSelect;
		//
		//return textField;
		//
	//}
	
	
	private function createShape (symbol:ShapeSymbol):Shape {
		
		var shape = new Shape ();
		
		for (command in symbol.commands) {
			
			switch (command.type) {
				
				case BEGIN_FILL: shape.graphics.beginFill (command.params[0], command.params[1]);
				case BEGIN_BITMAP_FILL: 
					
					#if nme
					
					var bitmap:BitmapSymbol = cast swf.symbols.get (command.params[0]);
					
					if (bitmap != null && bitmap.path != "") {
						
						var bitmapData = Assets.getBitmapData (bitmap.path);
						shape.graphics.beginBitmapFill (bitmapData, command.params[1], command.params[2], command.params[3]);
						
					}
					
					#end
					
				case END_FILL: shape.graphics.endFill ();
				case LINE_STYLE: 
					
					if (command.params.length > 0) {
						
						shape.graphics.lineStyle (command.params[0], command.params[1], command.params[2], command.params[3], command.params[4], command.params[5], command.params[6], command.params[7]);
						
					} else {
						
						shape.graphics.lineStyle ();
						
					}
				
				case MOVE_TO: shape.graphics.moveTo (command.params[0], command.params[1]);
				case LINE_TO: shape.graphics.lineTo (command.params[0], command.params[1]);
				case CURVE_TO: shape.graphics.curveTo (command.params[0], command.params[1], command.params[2], command.params[3]);
				default:
				
			}
			
		}
		
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
	
	
	private function enterFrame ():Void {
		
		if (lastUpdate == currentFrame) {
			
			currentFrame ++;
			
			if (currentFrame > totalFrames) {
				
				currentFrame = 1;
				
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
	
	
	private function getFrame (frame:Dynamic):Int {
		
		if (Std.is (frame, Int)) {
			
			return cast frame;
			
		} else if (Std.is (frame, String)) {
			
			// need to handle frame labels
			
		}
		
		return 1;
		
	}
	
	
	public override function gotoAndPlay (frame:Dynamic, scene:String = null):Void {
		
		currentFrame = getFrame (frame);
		update ();
		play ();
		
	}
	
	
	public override function gotoAndStop (frame:Dynamic, scene:String = null):Void {
		
		currentFrame = getFrame (frame);
		update ();
		stop ();
		
	}
	
	
	public override function nextFrame ():Void {
		
		var next = currentFrame + 1;
		
		if (next > totalFrames) {
			
			next = totalFrames;
			
		}
		
		gotoAndStop (next);
		
	}
	
	
	private function placeObject (displayObject:DisplayObject, frameObject:FrameObject):Void {
		
		if (frameObject.name != null) {
			
			displayObject.name = frameObject.name;
			
		}
		
		if (frameObject.matrix != null) {
			
			displayObject.transform.matrix = frameObject.matrix;
			
		}
		
		if (frameObject.colorTransform != null) {
			
			displayObject.transform.colorTransform = frameObject.colorTransform;
			
		}
		
	}
	
	
	public override function play ():Void {
		
		if (!playing && totalFrames > 1) {
			
			playing = true;
			clips.push (this);
			
		}
		
	}
	
	
	public override function prevFrame ():Void {
		
		var previous = currentFrame - 1;
		
		if (previous < 1) {
			
			previous = 1;
			
		}
		
		gotoAndStop (previous);
		
	}
	
	
	private function renderFrame (index:Int):Void {
		
		var frame = symbol.frames[index];
		
		//if (frame.frameNumber == currentFrame - 1 || frame.tweenType == null || frame.tweenType == "") {
		
		for (object in frame.objects) {
			
			if (swf.symbols.exists (object.id)) {
				
				var symbol = swf.symbols.get (object.id);
				var displayObject:DisplayObject = null;
				
				if (Std.is (symbol, SpriteSymbol)) {
					
					displayObject = new MovieClip (swf, cast symbol);
					
				} else if (Std.is (symbol, ShapeSymbol)) {
					
					displayObject = createShape (cast symbol);
					
				}
				
				if (displayObject != null) {
					
					placeObject (displayObject, object);
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
	
	
	public override function unflatten ():Void {
		
		lastUpdate = -1;
		update ();
		
	}
	
	
	private function update ():Void {
		
		if (currentFrame != lastUpdate) {
			
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
			
			var frameIndex = currentFrame - 1;
			
			if (frameIndex > -1) {
				
				renderFrame (frameIndex);
				
			}
			
		}
		
		lastUpdate = currentFrame;
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private static function stage_onEnterFrame (event:Event):Void {
		
		for (clip in clips) {
			
			clip.enterFrame ();
			
		}
		
	}
	
	
}