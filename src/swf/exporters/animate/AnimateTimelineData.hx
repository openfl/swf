package swf.exporters.animate;

import haxe.ds.Vector;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:noCompletion
class AnimateTimelineData
{
	public static inline var HAS_MATRIX = 1;
	public static inline var HAS_COLOR_TRANSFORM = 2;
	public static inline var HAS_FILTERS = 4;
	public static inline var HAS_NAME = 8;
	public static inline var HAS_BLEND_MODE = 16;
	public static inline var HAS_CACHE_AS_BITMAP = 32;
	public static inline var CACHE_AS_BITMAP = 64;
	public static inline var HAS_VISIBLE = 128;
	public static inline var VISIBLE = 256;
	public static inline var HAS_META_DATA = 512;

	public var frameCount(default, null):Int;
	public var frameOffsets(default, null):Array<Int>;
	public var objects(default, null):Vector<Float>;
	public var references(default, null):Array<Dynamic>;

	private var encodedObjects:Array<Float>;
	private var labelsByFrame:Map<Int, Array<String>>;
	private var scriptSourcesByFrame:Map<Int, String>;

	public function new(frames:Array<Dynamic>)
	{
		frameCount = frames != null ? frames.length : 0;
		frameOffsets = [];
		encodedObjects = [];

		if (frames == null)
		{
			frameOffsets.push(0);
			objects = new Vector<Float>(0);
			encodedObjects = null;
			return;
		}

		for (frameIndex in 0...frames.length)
		{
			var frameData:Dynamic = frames[frameIndex];
			frameOffsets.push(encodedObjects.length);

			if (Reflect.hasField(frameData, "label"))
			{
				if (labelsByFrame == null) labelsByFrame = new Map();
				labelsByFrame.set(frameIndex, [Reflect.field(frameData, "label")]);
			}
			else if (Reflect.hasField(frameData, "labels"))
			{
				if (labelsByFrame == null) labelsByFrame = new Map();
				labelsByFrame.set(frameIndex, Reflect.field(frameData, "labels"));
			}

			if (Reflect.hasField(frameData, "scriptSource"))
			{
				if (scriptSourcesByFrame == null) scriptSourcesByFrame = new Map();
				scriptSourcesByFrame.set(frameIndex, Reflect.field(frameData, "scriptSource"));
			}

			var frameObjects:Array<Dynamic> = Reflect.field(frameData, "objects");
			if (frameObjects != null)
			{
				for (frameObject in frameObjects)
				{
					__encodeFrameObject(frameObject);
				}
			}
		}

		frameOffsets.push(encodedObjects.length);
		objects = new Vector<Float>(encodedObjects.length);
		for (i in 0...encodedObjects.length)
		{
			objects[i] = encodedObjects[i];
		}
		encodedObjects = null;
	}

	public inline function getLabels(frameIndex:Int):Array<String>
	{
		return labelsByFrame != null ? labelsByFrame.get(frameIndex) : null;
	}

	public inline function getScriptSource(frameIndex:Int):String
	{
		return scriptSourcesByFrame != null ? scriptSourcesByFrame.get(frameIndex) : null;
	}

	public inline function getFrameStart(frameIndex:Int):Int
	{
		return frameOffsets[frameIndex];
	}

	public inline function getFrameEnd(frameIndex:Int):Int
	{
		return frameOffsets[frameIndex + 1];
	}

	public inline function getNextObjectPosition(position:Int):Int
	{
		var flags = Std.int(objects[position + 5]);
		position += 6;

		if ((flags & HAS_MATRIX) != 0) position += 6;
		if ((flags & HAS_COLOR_TRANSFORM) != 0) position += 8;
		if ((flags & HAS_FILTERS) != 0) position += 1 + Std.int(objects[position]);
		if ((flags & HAS_NAME) != 0) position++;
		if ((flags & HAS_BLEND_MODE) != 0) position++;
		if ((flags & HAS_META_DATA) != 0) position++;

		return position;
	}

	private function __addReference(value:Dynamic):Int
	{
		if (references == null) references = [];
		references.push(value);
		return references.length - 1;
	}

	private function __encodeFrameObject(frameObject:Dynamic):Void
	{
		var matrix:Array<Dynamic> = Reflect.field(frameObject, "matrix");
		var colorTransform:Array<Dynamic> = Reflect.field(frameObject, "colorTransform");
		var filters:Array<Array<Dynamic>> = Reflect.field(frameObject, "filters");
		var name:Dynamic = Reflect.field(frameObject, "name");
		var blendMode:Dynamic = Reflect.field(frameObject, "blendMode");
		var cacheAsBitmap:Dynamic = Reflect.field(frameObject, "cacheAsBitmap");
		var visible:Dynamic = Reflect.field(frameObject, "visible");
		var metaData:Dynamic = Reflect.field(frameObject, "metaData");
		var flags = 0;

		if (matrix != null) flags |= HAS_MATRIX;
		if (colorTransform != null) flags |= HAS_COLOR_TRANSFORM;
		if (filters != null) flags |= HAS_FILTERS;
		if (name != null) flags |= HAS_NAME;
		if (blendMode != null) flags |= HAS_BLEND_MODE;
		if (cacheAsBitmap != null)
		{
			flags |= HAS_CACHE_AS_BITMAP;
			if (cacheAsBitmap) flags |= CACHE_AS_BITMAP;
		}
		if (visible != null)
		{
			flags |= HAS_VISIBLE;
			if (visible) flags |= VISIBLE;
		}
		if (metaData != null) flags |= HAS_META_DATA;

		encodedObjects.push(Reflect.field(frameObject, "type"));
		encodedObjects.push(Reflect.field(frameObject, "id"));
		encodedObjects.push(Reflect.field(frameObject, "symbol"));
		encodedObjects.push(Reflect.field(frameObject, "depth"));
		encodedObjects.push(Reflect.field(frameObject, "clipDepth"));
		encodedObjects.push(flags);

		if (matrix != null)
		{
			for (value in matrix) encodedObjects.push(value);
		}

		if (colorTransform != null)
		{
			for (value in colorTransform) encodedObjects.push(value);
		}

		if (filters != null)
		{
			var lengthPosition = encodedObjects.length;
			encodedObjects.push(0);
			for (filter in filters)
			{
				if (filter == null || filter.length == 0) continue;

				encodedObjects.push(filter[0]);
				if (filter[0] == 1)
				{
					var matrixValues:Array<Dynamic> = filter[1];
					encodedObjects.push(matrixValues != null ? matrixValues.length : 0);
					if (matrixValues != null)
					{
						for (value in matrixValues) encodedObjects.push(value);
					}
				}
				else
				{
					for (i in 1...filter.length)
					{
						encodedObjects.push(filter[i] == true ? 1 : filter[i] == false ? 0 : filter[i]);
					}
				}
			}
			encodedObjects[lengthPosition] = encodedObjects.length - lengthPosition - 1;
		}

		if (name != null) encodedObjects.push(__addReference(name));
		if (blendMode != null) encodedObjects.push(__addReference(Std.string(blendMode)));
		if (metaData != null) encodedObjects.push(__addReference(metaData));
	}
}
