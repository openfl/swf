package format.swf.instance;

import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsLossless;
import format.swf.tags.TagDefineButton2;
import format.swf.tags.TagDefineEditText;
import format.swf.tags.TagDefineMorphShape;
import format.swf.tags.TagDefineShape;
import format.swf.tags.TagDefineSprite;
import format.swf.tags.TagDefineText;
import format.swf.tags.TagPlaceObject;
import format.swf.timeline.Frame;
import format.swf.timeline.FrameObject;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.Scene;
import openfl.display.Timeline;

class MovieClip extends #if flash flash.display.MovieClip.MovieClip2 #else openfl.display.MovieClip #end
{
	public function new(data:SWFTimelineContainer)
	{
		super(new MovieClipTimeline(data));
	}
}

class MovieClipTimeline extends Timeline
{
	@:noCompletion private var activeObjects:Array<ChildObject>;
	@:noCompletion private var data:SWFTimelineContainer;
	@:noCompletion private var movieClip:openfl.display.MovieClip;
	@:noCompletion private var objectPool:Map<Int, List<ChildObject>>;
	@:noCompletion private var previousFrame:Int;

	public function new(data:SWFTimelineContainer)
	{
		super();

		this.data = data;

		frameRate = @:privateAccess cast(data.rootTimelineContainer, SWFRoot).frameRate;
		scripts = [];

		var currentLabels = [];
		for (frame in data.frameLabels.keys())
		{
			var labels = data.frameLabels.get(frame);
			for (label in labels)
			{
				currentLabels.push(new openfl.display.FrameLabel(label, frame + 1));
			}
		}

		scenes = [new Scene("", currentLabels, data.frames.length)];
	}

	public override function attachMovieClip(movieClip:openfl.display.MovieClip):Void
	{
		this.movieClip = movieClip;

		objectPool = new Map<Int, List<ChildObject>>();
		activeObjects = [];
	}

	public override function enterFrame(frame:Int):Void
	{
		var frameIndex = frame - 1;

		if (frameIndex > -1)
		{
			renderFrame(frameIndex);
		}
	}

	@:noCompletion private inline function getDisplayObject(charId:Int):DisplayObject
	{
		var displayObject:DisplayObject = null;

		var symbol = data.getCharacter(charId);

		if (Std.is(symbol, TagDefineSprite))
		{
			displayObject = new MovieClip(cast symbol);
			var grid = data.getScalingGrid(charId);
			if (grid != null)
			{
				cast(displayObject, MovieClip).scale9Grid = grid.splitter.rect;
			}
		}
		else if (Std.is(symbol, TagDefineBitsLossless) || Std.is(symbol, TagDefineBits))
		{
			displayObject = new Bitmap(cast symbol);
		}
		else if (Std.is(symbol, TagDefineShape))
		{
			displayObject = new Shape(data, cast symbol);
		}
		else if (Std.is(symbol, TagDefineText))
		{
			displayObject = new StaticText(data, cast symbol);
		}
		else if (Std.is(symbol, TagDefineEditText))
		{
			displayObject = new DynamicText(data, cast symbol);
		}
		else if (Std.is(symbol, TagDefineButton2))
		{
			displayObject = new SimpleButton(data, cast symbol);
		}
		else if (Std.is(symbol, TagDefineMorphShape))
		{
			displayObject = new MorphShape(data, cast symbol);
		}
		else
		{
			// trace("Warning: No SWF Support for " + Type.getClassName(Type.getClass(symbol)));
		}

		return displayObject;
	}

	@:noCompletion private inline function placeObject(displayObject:DisplayObject, frameObject:FrameObject):Void
	{
		var firstTag:TagPlaceObject = cast data.tags[frameObject.placedAtIndex];
		var lastTag:TagPlaceObject = null;

		if (frameObject.lastModifiedAtIndex > 0)
		{
			lastTag = cast data.tags[frameObject.lastModifiedAtIndex];
		}

		if (lastTag != null && lastTag.hasName)
		{
			displayObject.name = lastTag.instanceName;
		}
		else if (firstTag.hasName)
		{
			displayObject.name = firstTag.instanceName;
		}

		if (lastTag != null)
		{
			if (lastTag.hasMatrix)
			{
				var matrix = lastTag.matrix.matrix.clone();
				matrix.tx *= 1 / 20;
				matrix.ty *= 1 / 20;

				if (Std.is(displayObject, DynamicText))
				{
					var offset = cast(displayObject, DynamicText).offset.clone();
					offset.concat(matrix);
					matrix = offset;
				}

				displayObject.transform.matrix = matrix;
			}
		}
		else if (firstTag.hasMatrix)
		{
			var matrix = firstTag.matrix.matrix.clone();
			matrix.tx *= 1 / 20;
			matrix.ty *= 1 / 20;

			if (Std.is(displayObject, DynamicText))
			{
				var offset = cast(displayObject, DynamicText).offset.clone();
				offset.concat(matrix);
				matrix = offset;
			}

			displayObject.transform.matrix = matrix;
		}

		if (lastTag != null)
		{
			if (lastTag.hasColorTransform)
			{
				displayObject.transform.colorTransform = lastTag.colorTransform.colorTransform;
			}
		}
		else if (firstTag.hasColorTransform)
		{
			displayObject.transform.colorTransform = firstTag.colorTransform.colorTransform;
		}

		if (lastTag != null)
		{
			if (lastTag.hasFilterList)
			{
				var filters = [];

				for (i in 0...lastTag.surfaceFilterList.length)
				{
					filters[i] = lastTag.surfaceFilterList[i].filter;
				}

				displayObject.filters = filters;
			}
		}
		else if (firstTag.hasFilterList)
		{
			var filters = [];

			for (i in 0...firstTag.surfaceFilterList.length)
			{
				filters[i] = firstTag.surfaceFilterList[i].filter;
			}

			displayObject.filters = filters;
		}

		if (Std.is(displayObject, MorphShape))
		{
			if (lastTag != null) cast(displayObject, MorphShape).render(lastTag.ratio);
		}

		Reflect.setField(movieClip, displayObject.name, displayObject);
	}

	@:noCompletion private inline function renderFrame(index:Int):Void
	{
		var frame:Frame = data.frames[index];
		var sameCharIdList:List<ChildObject>;

		if (frame != null)
		{
			var frameObject:FrameObject = null;

			var newActiveObjects:Array<ChildObject> = [];

			// Check previously active objects (Maintain or remove)

			for (activeObject in activeObjects)
			{
				frameObject = frame.objects.get(activeObject.frameObject.depth);

				if (frameObject == null || frameObject.characterId != activeObject.frameObject.characterId)
				{
					// The The frameObject isn't the same as the active
					// Return object to pool

					sameCharIdList = objectPool.get(activeObject.frameObject.characterId);
					if (sameCharIdList == null)
					{
						sameCharIdList = new List<ChildObject>();
						objectPool.set(activeObject.frameObject.characterId, sameCharIdList);
					}
					sameCharIdList.push(activeObject);

					// Remove the object from the display list
					// todo - disconnect event handlers ?
					movieClip.removeChild(activeObject.object);

					if (activeObject.object.name != null && Reflect.hasField(movieClip, activeObject.object.name))
					{
						Reflect.deleteField(movieClip, activeObject.object.name);
					}
				}
				else
				{
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

			for (object in frame.getObjectsSortedByDepth())
			{
				child = null;
				activeIdx = activeObjects.length - 1;

				// Check if it's in the active objects
				if (activeIdx > -1)
				{
					while (activeIdx > -1
						&& (activeObjects[activeIdx].frameObject.characterId != object.characterId
							|| (activeObjects[activeIdx].frameObject.characterId == object.characterId
								&& activeObjects[activeIdx].frameObject.depth != object.depth)))
					{
						activeIdx--;
					}
				}

				if (activeIdx > -1)
				{
					// Object in the activeObjects Array, no need to create, just set the frameObject
					child = activeObjects[activeIdx];
					child.frameObject = object;
					displayObject = child.object;
				}
				else
				{
					// Not in the active objects, search in the Pool (For each char ID there's a list of ChildObjects, because the same symbol may be instantiated more than once)

					sameCharIdList = objectPool.get(object.characterId);
					if (sameCharIdList != null && !sameCharIdList.isEmpty())
					{
						// Object already created and in the pool

						child = sameCharIdList.pop();
						child.frameObject = object;
						activeObjects.push(child);

						// if (sameCharIdList.isEmpty()) objectPool.remove(object.characterId); // No need to remove the list, just leave it empty

						displayObject = child.object;
					}
					else
					{
						// We have to create it
						displayObject = getDisplayObject(object.characterId);

						if (displayObject != null)
						{
							activeObjects.push(child = {object: displayObject, frameObject: object});
						}
					}
				}

				if (displayObject != null)
				{
					placeObject(displayObject, object);

					if (mask != null)
					{
						if (mask.frameObject.clipDepth < object.depth)
						{
							mask = null;
						}
						else
						{
							displayObject.mask = mask.object;
						}
					}
					else
					{
						displayObject.mask = null;
					}

					if (object.clipDepth != 0 #if neko && object.clipDepth != null #end)
					{
						mask = child;
						displayObject.visible = false;
					}

					movieClip.addChild(displayObject);
				}
			}
		}
	}
}

typedef ChildObject =
{
	var object:DisplayObject;
	var frameObject:FrameObject;
}
