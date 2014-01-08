package format.swf.instance;


import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.events.Event;
import flash.Lib;
import format.swf.data.SWFButtonRecord;
import format.swf.SWFTimelineContainer;
import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsLossless;
import format.swf.tags.TagDefineButton2;
import format.swf.tags.TagDefineEditText;
import format.swf.tags.TagDefineFont;
import format.swf.tags.TagDefineShape;
import format.swf.tags.TagDefineSprite;
import format.swf.tags.TagDefineText;
import format.swf.tags.TagPlaceObject;
import format.swf.timeline.FrameObject;


class SimpleButton extends flash.display.SimpleButton {
	
	
	private var data:SWFTimelineContainer;
	private var tag:TagDefineButton2;
	private var lastUpdate:Int;
	
	
	
	
	public function new (data:SWFTimelineContainer, tag:TagDefineButton2) {
		
		super ();
		
		this.data = data;
		this.tag = tag;
		
		//trace(tag.characters);
		var rec:SWFButtonRecord;
		for (i in 0...tag.characters.length) {
			rec = tag.characters[i];
			trace(i + ": " + rec);
		}
		
		
		update ();
		
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
	
	
	
	
	
	
	private function update ():Void {
		
		/*if (__currentFrame != lastUpdate) {
			
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
			
		}
		
		lastUpdate = __currentFrame;*/
		
	}
	
}