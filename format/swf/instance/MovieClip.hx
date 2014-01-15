package format.swf.instance;


import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.events.Event;
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
	
	private var objectPool:Map<Int, ChildObject>;
	private var activeObjects:Array<ChildObject>;
	
	#if flash
	private var __currentFrame:Int;
	private var __totalFrames:Int;
	#end
	
	
	
	public function new (data:SWFTimelineContainer) {
		
		super ();
		
		this.data = data;
		
		if (!initialized) {
			
			clips = new Array <MovieClip> ();
			initialized = true;
			
		}
		
		__currentFrame = 1;
		__totalFrames = data.frames.length;
		
		objectPool = new Map<Int, ChildObject>();
		activeObjects = [];
		
		update ();
		
		if (__totalFrames > 1) {
			
			//play ();
			
		}
		
	}
	
	
	private inline function applyTween (start:Float, end:Float, ratio:Float):Float {
		
		return start + ((end - start) * ratio);
		
	}
	
	
	private function enterFrame ():Void {
		//trace(" :: " +  this.name + ": EnterFrame");
		
		if (lastUpdate == __currentFrame) {
			
			__currentFrame ++;
			
			if (__currentFrame > __totalFrames) {
				
				__currentFrame = 1;
				
			}
			
		}
		
		
		update ();
		
	}
	
	
	public /*override*/ function flatten ():Void {
		
		//trace("Flatten : " + this.name);
		
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
			
			//trace(".bitmapAdded");
			
			var bitmap = new flash.display.Bitmap (bitmapData);
			bitmap.smoothing = true;
			bitmap.x = bounds.left;
			bitmap.y = bounds.top;
			addChild (bitmap);
			
			
			//trace("...childAt[0]: " + this.getChildAt(0) + " - numChildren: " + this.numChildren);
			//trace("parent: " + parent.name);
		}
		
		
		
		stop();
		
	}
	
	
	private function getFrame (frame:Dynamic):Int {
		
		var value = 1;
		
		if (Std.is (frame, Int)) {
			
			value = cast frame;
			
		} else if (Std.is (frame, String)) {
			
			// need to handle frame labels
			
		}
		
		if (value < 1) value = 1;
		if (value > __totalFrames) value = __totalFrames;
		
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
		
		//trace("place: " + displayObject.name + " - charID: " + frameObject.characterId);
		if (displayObject.name == "over" || displayObject.name == "container") {
			//trace("...childAt[0]: " + untyped displayObject.getChildAt(0) + " - numChildren: " + untyped displayObject.numChildren);
		}
		
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
		
	}
	
	
	public override function play ():Void {
		
		//trace(" :: " + this.name + ":PLAY  - playing: " + playing + " - __totalFrames: " + __totalFrames);
		
		if (!playing && __totalFrames > 1) {
			
			playing = true;
			clips.push (this);
			
			Lib.current.stage.removeEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
			Lib.current.stage.addEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
			
			//trace("EnterFrame ON");
			
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
		
		//trace(" :: " + this.name + ": Rendering Frame " + index);
		
		
		var frame:Frame = data.frames[index];
		if (frame == null) {
			return;
		}
		
		var frameObject:FrameObject = null;
		
		var newActiveObjects:Array<ChildObject> = [];
		
		// Check previously active objects (Maintain or remove)
		
		for (activeObject in activeObjects) {
			if (activeObject.frameObject != null) {
				// Normal active object
				frameObject = frame.objects.get(activeObject.frameObject.depth);
				
				if (frameObject == null || frameObject.characterId != activeObject.frameObject.characterId) {
					// The frameObject isn't the same as the active
					// Return object to pool
					objectPool.set(activeObject.frameObject.characterId, activeObject);
					
					// Remove the object from the display list
					// todo - disconnect event handlers ?
					removeChild(activeObject.object);
				} else {
					
					newActiveObjects.push(activeObject);
					
				}
				
			} /*else {
				// Foreign active object
				newActiveObjects.push(activeObject);
			}*/
		}
		
		// splice actives?
		activeObjects = newActiveObjects;
		
		// Check possible new objects
		//var object:FrameObject;
		var displayObject:DisplayObject;
		var child:ChildObject;
		
		var activeIdx:Int;
		
		for (object in frame.getObjectsSortedByDepth ()) {
			child = null;
			
			//trace(" - search for: " + object.characterId);
			//trace(" - .. actives: " + activeObjects);
			activeIdx = activeObjects.length - 1;
			// Check if it's in the active objects
			while (activeIdx > -1 && activeObjects[activeIdx].frameObject.characterId != object.characterId) { 
				activeIdx--;
			}
			
			if (activeIdx > -1) {
				child = activeObjects[activeIdx];
				child.frameObject = object;
				displayObject = child.object;
				//trace(" - .. IN ACtives");
			} else {
				
				//trace(" - .. not IN ACtives... searching in pool");
				//trace(" - .. " + objectPool.keys());
				child = objectPool.get(object.characterId);
				if (child != null) {
					//trace(" - .. IN POOL!");
					// DisplayObject already created and in the pool
					child.frameObject = object;
					activeObjects.push(child);
					objectPool.remove(object.characterId);
					displayObject = child.object;
				} else {
					// We have to create it
					displayObject = getDisplayObject(object.characterId);
					//trace("!!!CREATED: charID: " + object.characterId);
					
					if (displayObject != null) {
						activeObjects.push( { object:displayObject, frameObject:object } );
					}
				}
			}
			
			if (displayObject != null) {
				
				placeObject (displayObject, object);
				addChild(displayObject);
			}
			
		}
		
	}
	
	private inline function getDisplayObject(charId:Int):DisplayObject {
		
		var displayObject:DisplayObject = null;
			
		var symbol = data.getCharacter (charId);
		var grid = data.getScalingGrid (charId);
		
		if (Std.is (symbol, TagDefineSprite)) {
				
			displayObject = new MovieClip (cast symbol);
			
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
		
		if (displayObject != null) {
			
			if (grid != null) {
				
				displayObject.scale9Grid = grid.splitter.rect.clone ();
				
			}
		}
		
		return displayObject;
	}
	
	
	public override function stop ():Void {
		
		//trace(" :: " + this.name + ":STOP  - playing: " + playing);
		
		
		if (playing) {
			
			//Lib.current.stage.removeEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
			
			playing = false;
			clips.remove (this);
			
			if (clips.length == 0) Lib.current.stage.removeEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
			
			//trace("clips: " + clips);
			
		}
		
	}
	
	
	public /*override*/ function unflatten ():Void {
		
		lastUpdate = -1;
		update ();
		
	}
	
	
	private function update ():Void {
		//trace( ":: " + this.name + ": __currentFrame: " + __currentFrame + " - lastUpdate: " + lastUpdate);
		if (__currentFrame != lastUpdate) {
			
			/*for (i in 0...numChildren) {
				
				var child = getChildAt (0);
				
				if (Std.is (child, MovieClip)) {
					
					untyped child.stop ();
					
				}
				
				removeChildAt (0);
				
			}*/
			
			var frameIndex = __currentFrame - 1;
			
			//trace( ":: " + this.name + ": frameIndex: " + frameIndex);
			
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
		
		//trace("EF");
		
		for (clip in clips) {
			
			clip.enterFrame ();
			
		}
		
	}
	
	
}
