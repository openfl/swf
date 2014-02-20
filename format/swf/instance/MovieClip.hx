package format.swf.instance;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.FrameLabel;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import format.swf.instance.MovieClip.ChildObject;
import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsLossless;
import format.swf.tags.TagDefineButton2;
import format.swf.tags.TagDefineEditText;
import format.swf.tags.TagDefineFont;
import format.swf.tags.TagDefineShape;
import format.swf.tags.TagDefineSprite;
import format.swf.tags.TagDefineText;
import format.swf.tags.TagPlaceObject;
import format.swf.timeline.Frame;
import format.swf.timeline.FrameObject;


typedef ChildObject = {
	var object:DisplayObject;
	var frameObject:FrameObject;
}

class MovieClip extends flash.display.MovieClip {
	
	
	private static var clips:Array <MovieClip>;
	private static var initialized:Bool;
	
	private var data:SWFTimelineContainer;
	private var lastUpdate:Int;
	private var playing:Bool;
	
	private var objectPool:Map<Int, List<ChildObject>>;
	private var activeObjects:Array<ChildObject>;
	
	#if flash
	private var __currentFrame:Int;
	private var __currentFrameLabel:String;
	private var __currentLabel:String;
	private var __currentLabels:Array<FrameLabel>;
	private var __totalFrames:Int;
	#end
	
	public var scale9BitmapGrid(get, set):Rectangle;
	private var _scale9BitmapGrid:Rectangle;
	private var _scale9BitmapData:BitmapData;
	private var _scale9ScaleX:Float = 1;
	private var _scale9ScaleY:Float = 1;
	
	public function new (data:SWFTimelineContainer) {
		
		super ();
		
		this.data = data;
		
		if (!initialized) {
			
			clips = new Array <MovieClip> ();
			initialized = true;
			
		}
		
		__currentFrame = 1;
		__totalFrames = data.frames.length;

		for (frame in data.frameLabels.keys ()) {

			__currentLabels.push (new FrameLabel (data.frameLabels.get (frame), frame + 1));

		}
		
		objectPool = new Map<Int, List<ChildObject>>();
		activeObjects = [];
		
		update ();
		
		if (__totalFrames > 1) {
			
			play ();
			
		}
		
	}
	
	#if flash
	@:setter(scaleX)
	public function set_scaleX(val:Float):Void
	{
		//trace("set scaleX");
		if (_scale9BitmapGrid == null) super.scaleX = val;
		else {
			super.scaleX = 1;
			_scale9ScaleX = val;
			drawScale9BitmapData();
		}
	}
	@:getter(scaleX)
	public function get_scaleX():Float {
		if (_scale9BitmapGrid == null) return super.scaleX;
		else return _scale9ScaleX;
	}
	
	@:setter(scaleY)
	public function set_scaleY(val:Float):Void
	{
		if (_scale9BitmapGrid == null) super.scaleY = val;
		else {
			super.scaleY = 1;
			_scale9ScaleY = val;
			drawScale9BitmapData();
		}
	}
	@:getter(scaleY)
	public function get_scaleY():Float {
		if (_scale9BitmapGrid == null) return super.scaleY;
		else return _scale9ScaleY;
	}
	
	
	@:setter(width)
	public function set_width(val:Float):Void
	{
		//trace("set width");
		if (_scale9BitmapGrid == null) super.width = val;
		else {
			_scale9ScaleX = val / _scale9BitmapData.width;
			drawScale9BitmapData();
		}
	}
	
	@:setter(height)
	public function set_height(val:Float):Void
	{
		//trace("set height");
		if (_scale9BitmapGrid == null) super.height = val;
		else {
			_scale9ScaleY = val / _scale9BitmapData.height;
			drawScale9BitmapData();
		}
	}
	#end
		
	private function get_scale9BitmapGrid():Rectangle {
		return _scale9BitmapGrid;
	}
	private function set_scale9BitmapGrid(value:Rectangle):Rectangle {
		
		_scale9BitmapGrid = value;
		if (_scale9BitmapGrid != null) { 
			
			flatten();
			
			var bmp:flash.display.Bitmap = cast(getChildAt(0), flash.display.Bitmap);
			
			_scale9BitmapData = bmp.bitmapData;
	
			drawScale9BitmapData();
			removeChild(bmp);
			
		} else {
			unflatten();
		}
		//trace("Scale9 set");
		
		return value;
	}
	private inline function drawScale9BitmapData():Void {
		if (_scale9BitmapData != null) {
			drawScale9Bitmap(_scale9BitmapData, _scale9BitmapData.width * _scale9ScaleX, _scale9BitmapData.height * _scale9ScaleY, _scale9BitmapGrid, null);
		}
	}
	
	private function drawScale9Bitmap(bitmap : BitmapData,			// bitmap data source
								width:Float,					// draw width
								height:Float,					// draw height
								inner : Rectangle,				// inner rectangle (relative to 0,0)
								outer : Rectangle=null):Void{	// outer rectangle (relative to 0,0)
		
		// some useful local vars
		var x:Int, y:Int, i:Int, j:Int;
		var ox:Float=0, oy:Float;
		var dx : Float = 0, dy : Float;
		var wid:Float, hei:Float;
		var dwid:Float, dhei : Float;
		var sw : Int = bitmap.width;
		var sh : Int = bitmap.height;
		
		graphics.clear();
		
		//trace("Scale Draw " + width + ", " + height);
		
		// outer null ?
		if (outer==null){
			outer = new Rectangle(0,0,sw,sh);
		}
		
		
		// matrix creation
		var mat : Matrix = new Matrix();
		
		// pre-calculate widths
		var widths : Array<Float>=[	inner.left,
								inner.width,
								sw - inner.right];

		// pre-calculate heights
		var heights : Array<Float>=[	inner.top,
								inner.height,
								sh - inner.bottom];
								
		// resized part 
		var resize : Point = new Point(	width - widths[0] - widths[2],
										height - heights[0] - heights[2]);

		// let's draw
		//for (x=0;x<3;x++){
		for (x in 0...3) {
			
			// original width
			wid = widths[x];
			
			// draw width						
			dwid = x==1 ? resize.x : widths[x];
			

			// original & draw offset
			dy=oy=0;
			
			//for (y=0;y<3;y++){
			for (y in  0...3){
				
				// original & draw height
				hei = heights[y];
				dhei = y==1 ? resize.y : heights[y];
	
				if (dwid > 0 && dhei > 0) {
					
					// some matrix computation
					mat.a=dwid/wid;
					mat.d=dhei/hei;
					mat.tx=-ox*mat.a + dx;
					mat.ty=-oy*mat.d + dy;
					mat.translate(-outer.left,-outer.top);
					
					// draw the cell
					graphics.beginBitmapFill(bitmap,mat,false,true);
					graphics.drawRect(dx - outer.left, dy - outer.top, dwid, dhei);
					graphics.endFill();
				}
				
				
				// offset incrementation
				oy += hei;
				dy += dhei;
			}
			
			// offset incrementation
			ox += wid;
			dx += dwid;
		}
	}
	
	
	
	private inline function applyTween (start:Float, end:Float, ratio:Float):Float {
		
		return start + ((end - start) * ratio);
		
	}
	
	
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
		
		var value = 1;
		
		if (Std.is (frame, Int)) {
			
			value = cast frame;
			if (value < 1) value = 1;
			if (value > __totalFrames) value = __totalFrames;
			
		} else if (Std.is (frame, String)) {
			if (data.frameIndexes.exists(cast frame))
				value = data.frameIndexes.get(cast frame);
			else
				value = 1;
		}
		
		return value;
		
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
	
	
	private inline function placeObject (displayObject:DisplayObject, frameObject:FrameObject):Void {
		
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
		
		var oldScaleX:Float = displayObject.scaleX;
		var oldScaleY:Float = displayObject.scaleY;
		
		var sx:Float;
		var sy:Float;
		
		if (lastTag != null && lastTag.hasMatrix) {
			
			var matrix = lastTag.matrix.matrix;
			matrix.tx *= 1 / 20;
			matrix.ty *= 1 / 20;
			
			if (Std.is (displayObject, DynamicText)) {
				
				var offset = cast (displayObject, DynamicText).offset.clone ();
				offset.concat (matrix);
				matrix = offset;
				
			}
			
			displayObject.transform.matrix = matrix;
			
		} else if (firstTag.hasMatrix) {
			
			var matrix = firstTag.matrix.matrix;
			matrix.tx *= 1 / 20;
			matrix.ty *= 1 / 20;
			
			if (Std.is (displayObject, DynamicText)) {
				
				var offset = cast (displayObject, DynamicText).offset.clone ();
				offset.concat (matrix);
				matrix = offset;
				
			}
			
			displayObject.transform.matrix = matrix;
			
		}
		
		//trace(displayObject.name + " W, H : " + displayObject.scaleX + ", " + displayObject.scaleY + " - vs - " + oldScaleX + ", " + oldScaleY);
		if (Std.is(displayObject, MovieClip)) {
			var mc = cast(displayObject, MovieClip);
			if (mc.scale9BitmapGrid != null && (mc.transform.matrix.a != oldScaleX || mc.transform.matrix.d != oldScaleY)) {
				
				mc._scale9ScaleX = mc.transform.matrix.a;
				mc._scale9ScaleY = mc.transform.matrix.d;
				
				var mt:Matrix = mc.transform.matrix;
				
				mt.a = 1;
				mt.d = 1;
				
				mc.transform.matrix = mt;
				
				mc.drawScale9BitmapData();
			}
		}
		
		
		
		if (lastTag != null && lastTag.hasColorTransform) {
			
			displayObject.transform.colorTransform = lastTag.colorTransform.colorTransform;
			
		} else if (firstTag.hasColorTransform) {
			
			displayObject.transform.colorTransform = firstTag.colorTransform.colorTransform;
			
		}
		
		if (lastTag != null && lastTag.hasFilterList) {
			
			var filters = [];
			
			for (i in 0...lastTag.surfaceFilterList.length) {
				
				filters[i] = lastTag.surfaceFilterList[i].filter;
				
			}
			
			displayObject.filters = filters;
			
		} else if (firstTag.hasFilterList) {
			
			var filters = [];
			
			for (i in 0...firstTag.surfaceFilterList.length) {
				
				filters[i] = firstTag.surfaceFilterList[i].filter;
				
			}
			
			displayObject.filters = filters;
			
		}
		
		
		//trace("placeObject " + displayObject.name + ": grid: " + displayObject.scale9Grid);
		//if (displayObject.name == "withGrid") trace(".child0 :" + (untyped displayObject.getChildAt(0)));
		
	}
	
	
	public override function play ():Void {
		
		if (!playing && __totalFrames > 1) {
			
			playing = true;
			clips.push (this);
			
			Lib.current.stage.removeEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
			Lib.current.stage.addEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
			
		}
		
	}
	
	
	public override function prevFrame ():Void {
		
		var previous = __currentFrame - 1;
		
		if (previous < 1) {
			
			previous = 1;
			
		}
		
		gotoAndStop (previous);
		
	}
	
	
	private inline function renderFrame (index:Int):Void {
		
		var frame:Frame = data.frames[index];
		var sameCharIdList:List<ChildObject>;
		
		if (frame != null) {
			
			var frameObject:FrameObject = null;
			
			var newActiveObjects:Array<ChildObject> = [];
			
			// Check previously active objects (Maintain or remove)
			
			for (activeObject in activeObjects) {
				
				frameObject = frame.objects.get(activeObject.frameObject.depth);
				
				if (frameObject == null || frameObject.characterId != activeObject.frameObject.characterId) {
					// The The frameObject isn't the same as the active
					// Return object to pool
					
					sameCharIdList = objectPool.get(activeObject.frameObject.characterId);
					if (sameCharIdList == null) {
						sameCharIdList = new List<ChildObject>();
						objectPool.set(activeObject.frameObject.characterId, sameCharIdList);
					}
					sameCharIdList.push (activeObject);
					
					// Remove the object from the display list
					// todo - disconnect event handlers ?
					removeChild(activeObject.object);
				} else {
					newActiveObjects.push(activeObject);
				}
			}
			
			activeObjects = newActiveObjects;
			
			// Check possible new objects
			// For each FrameObject inside the frame, check if it already exists in the activeObjects array, then check in the Pool, and if it's not there, create the DisplayObject
			var displayObject:DisplayObject;
			var child:ChildObject;
			var mask:ChildObject = null;
			
			var activeIdx:Int;
			
			for (object in frame.getObjectsSortedByDepth ()) {
				child = null;
				activeIdx = activeObjects.length - 1;
				
				// Check if it's in the active objects
				if (activeIdx > -1) {
					
					while (activeIdx > -1 && (activeObjects[activeIdx].frameObject.characterId != object.characterId || ( activeObjects[activeIdx].frameObject.characterId == object.characterId && activeObjects[activeIdx].frameObject.depth != object.depth))) { 
						activeIdx--;
					}
					
				}
				
				if (activeIdx > -1) {
					
					// Object in the activeObjects Array, no need to create, just set the frameObject
					child = activeObjects[activeIdx];
					child.frameObject = object;
					displayObject = child.object;
					
				} else {
					
					// Not in the active objects, search in the Pool (For each char ID there's a list of ChildObjects, because the same symbol may be instantiated more than once)
					
					sameCharIdList = objectPool.get(object.characterId);
					if (sameCharIdList != null && !sameCharIdList.isEmpty()) {
						
						// Object already created and in the pool
						
						child = sameCharIdList.pop();
						child.frameObject = object;
						activeObjects.push(child);
						
						//if (sameCharIdList.isEmpty()) objectPool.remove(object.characterId); // No need to remove the list, just leave it empty
						
						displayObject = child.object;
						
					} else {
						
						// We have to create it
						displayObject = getDisplayObject(object.characterId);
						
						if (displayObject != null) {
							activeObjects.push( child = { object:displayObject, frameObject:object } );
						}
						
					}
				}
				
				if (displayObject != null) {
					
					placeObject (displayObject, object);
					
					addChild(displayObject);
				}

				if (mask != null) {

					if (mask.frameObject.clipDepth < object.depth) {

						mask = null;

					} else {

						displayObject.mask = mask.object;
					
					}
				} else {

					displayObject.mask = null;

				}

				if (object.clipDepth != 0) {

					mask = child;
					displayObject.visible = false;

				}
				
			}
		}
		
	}
	
	private inline function getDisplayObject(charId:Int):DisplayObject {
		
		var displayObject:DisplayObject = null;
		
		var symbol = data.getCharacter (charId);
		
		if (Std.is (symbol, TagDefineSprite)) {
				
			displayObject = new MovieClip (cast symbol);
			var grid = data.getScalingGrid (charId);
			if (grid != null) {
				var rect:Rectangle = grid.splitter.rect.clone ();
				
				cast (displayObject, MovieClip).scale9BitmapGrid = rect;
				
			}
			
		} else if (Std.is (symbol, TagDefineBitsLossless) || Std.is (symbol, TagDefineBits)) {
			
			displayObject = new Bitmap (cast symbol);
			
		} else if (Std.is (symbol, TagDefineShape)) {
			
			displayObject = new Shape (data, cast symbol);
			
		} else if (Std.is (symbol, TagDefineText)) {
			
			displayObject = new StaticText (data, cast symbol);
			
		} else if (Std.is (symbol, TagDefineEditText)) {
			
			displayObject = new DynamicText (data, cast symbol);
			
		} else if (Std.is (symbol, TagDefineButton2)) {
			displayObject = new SimpleButton(data, cast symbol);
		}
		
		return displayObject;
	}
	
	
	public override function stop ():Void {
		
		if (playing) {
			
			playing = false;
			clips.remove (this);
			
			if (clips.length == 0) Lib.current.stage.removeEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
			
		}
		
	}
	
	
	public /*override*/ function unflatten ():Void {
		
		lastUpdate = -1;
		update ();
		
	}
	
	
	private function update ():Void {

		if (__currentFrame != lastUpdate) {
			
			var frameIndex = __currentFrame - 1;
			
			if (frameIndex > -1) {
				
				renderFrame (frameIndex);
				
			}

			var frame = data.frames[frameIndex];

			__currentFrameLabel = frame.label;

			if (frameIndex == 0 || frame.label != null) {

				__currentLabel = frame.label;

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
