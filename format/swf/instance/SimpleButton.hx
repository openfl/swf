package format.swf.instance;


import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import flash.events.Event;
import flash.Lib;
import format.swf.data.SWFButtonRecord;
import format.swf.SWFTimelineContainer;
import format.swf.tags.IDefinitionTag;
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
		
		var displayObject:DisplayObject;
		var stateSprite:Sprite = null;
		//trace(tag.characters);
		var rec:SWFButtonRecord;
		for (i in 0...tag.characters.length) {
			rec = tag.characters[i];
			trace(i + ": " + rec);
			
			if (rec.stateUp) {
				if (this.upState == null) this.upState = new Sprite();
				displayObject = getDisplayObject(rec.characterId);
				if (displayObject != null) placeButtonRecord(displayObject, rec, this.upState);
			}
			if (rec.stateOver) {
				if (this.overState == null) this.overState = new Sprite();
				displayObject = getDisplayObject(rec.characterId);
				if (displayObject != null)  cast (this.overState, Sprite).addChild(displayObject);
			}
			if (rec.stateDown) {
				if (this.downState == null) this.downState = new Sprite();
				displayObject = getDisplayObject(rec.characterId);
				if (displayObject != null)  cast (this.downState, Sprite).addChild(displayObject);
			}
			if (rec.stateHitTest) {
				if (this.hitTestState == null) this.hitTestState = new Sprite();
				displayObject = getDisplayObject(rec.characterId);
				if (displayObject != null)  cast (this.hitTestState, Sprite).addChild(displayObject);
			}
			
		}
		
		
		update ();
		
	}
	
	private inline function getDisplayObject(charId:Int):DisplayObject {
		var symbol = data.getCharacter (charId);
		//var grid = data.getScalingGrid (charId);
		var displayObject:DisplayObject = null;
		
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
			
			//if (grid != null) {
				//
				//displayObject.scale9Grid = grid.splitter.rect.clone ();
				//
			//}
		}
		
		return displayObject;
		
		
	}
	
	private inline function placeButtonRecord(displayObject:DisplayObject, record:SWFButtonRecord, container:DisplayObject) :Void {
		if (record.placeMatrix != null) {
			trace(record.placeMatrix.matrix);
			displayObject.transform.matrix = new Matrix(record.placeMatrix.matrix.a, record.placeMatrix.matrix.b, record.placeMatrix.matrix.c, record.placeMatrix.matrix.d, record.placeMatrix.matrix.tx / 20, record.placeMatrix.matrix.ty / 20);
		}
		
		if (record.hasFilterList) {
			var filters:Array<BitmapFilter> = [];
			
			for (i in 0...record.filterList.length) {
				filters.push(record.filterList[i].filter);
			}
			displayObject.filters = filters;
		}
		
		//if (record.hasBlendMode) {
			//displayObject.blendMode = record;
		//}
		
		//if (record.colorTransform != null) {
			//displayObject.transform.colorTransform = record.colorTransform.colorTransform;
		//}
		
		//cast(container, Sprite).addChildAt(displayObject, record.placeDepth-1);
		cast(container, Sprite).addChild(displayObject);
	}

	/*private function placeObject (displayObject:DisplayObject, frameObject:FrameObject):Void {
		
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
		
	}*/
	
	
	
	
	
	
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