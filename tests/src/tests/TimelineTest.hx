package tests;

import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Shape;
import swf.exporters.animate.AnimateFrame;
import swf.exporters.animate.AnimateFrameObject;
import swf.exporters.animate.AnimateFrameObjectType;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateShapeSymbol;
import swf.exporters.animate.AnimateSpriteSymbol;
import swf.exporters.animate.AnimateTimeline;
import swf.exporters.swflite.SWFLite;
import swf.exporters.swflite.ShapeSymbol;
import swf.exporters.swflite.SpriteSymbol;
import swf.exporters.swflite.timeline.Frame;
import swf.exporters.swflite.timeline.FrameObject;
import swf.exporters.swflite.timeline.FrameObjectType;
import swf.exporters.swflite.timeline.SymbolTimeline;
import utest.Assert;
import utest.Test;

@:access(openfl.display.DisplayObject)
@:access(swf.exporters.animate)
@:access(swf.exporters.swflite)
class TimelineTest extends Test
{
	public function testTimelinesCompile():Void
	{
		// both timelines must compile on every target, including Flash
		Assert.notNull(Type.getClassName(AnimateTimeline));
		Assert.notNull(Type.getClassName(SymbolTimeline));
	}

	#if !flash
	public function testAnimateClippingCharacterWithoutTargetIsMask():Void
	{
		var clip = createAnimateClip([[animateObject(AnimateFrameObjectType.CREATE, 0, 1, 5)]]);
		Assert.isTrue(clip.getChildAt(0).__isMask);
	}

	public function testSWFLiteClippingCharacterWithoutTargetIsMask():Void
	{
		var clip = createSWFLiteClip([[swfLiteObject(FrameObjectType.CREATE, 0, 1, 5)]]);
		Assert.isTrue(clip.getChildAt(0).__isMask);
	}

	public function testAnimateClipDepthChangeCreatesNewInstance():Void
	{
		var clip = createAnimateClip([
			[animateObject(AnimateFrameObjectType.CREATE, 0, 1, 0)],
			[animateObject(AnimateFrameObjectType.DESTROY, 0, 1, 0), animateObject(AnimateFrameObjectType.CREATE, 1, 1, 3)]
		]);
		checkClipDepthChange(clip);
	}

	public function testSWFLiteClipDepthChangeCreatesNewInstance():Void
	{
		var clip = createSWFLiteClip([
			[swfLiteObject(FrameObjectType.CREATE, 0, 1, 0)],
			[swfLiteObject(FrameObjectType.DESTROY, 0, 1, 0), swfLiteObject(FrameObjectType.CREATE, 1, 1, 3)]
		]);
		checkClipDepthChange(clip);
	}

	public function testAnimateNamedChildrenAreAssignedPerClass():Void
	{
		// instance fields are cached by class, so each class must still get its own fields
		var library = createAnimateLibrary();
		var symbolA = addAnimateSprite(library, 10, Type.getClassName(TimelineFieldClipA), [[animateObject(AnimateFrameObjectType.CREATE, 0, 1, 0, "first")]]);
		var symbolB = addAnimateSprite(library, 11, Type.getClassName(TimelineFieldClipB), [[animateObject(AnimateFrameObjectType.CREATE, 0, 1, 0, "second")]]);

		var a1:TimelineFieldClipA = cast symbolA.__createObject(library);
		var b:TimelineFieldClipB = cast symbolB.__createObject(library);
		var a2:TimelineFieldClipA = cast symbolA.__createObject(library);

		Assert.notNull(a1.first);
		Assert.notNull(a2.first);
		Assert.notNull(b.second);
		Assert.notEquals(a1.first, a2.first);
		library.unload();
	}

	private static function checkClipDepthChange(clip:MovieClip):Void
	{
		clip.gotoAndStop(1);
		var first = clip.getChildAt(0);
		// __isMask is not initialized on display objects that never were masks
		Assert.isTrue(first.__isMask != true);

		// the same character at the same depth, now with a clip depth, is a new mask instance
		clip.gotoAndStop(2);
		var second = clip.getChildAt(0);
		Assert.notEquals(first, second);
		Assert.isTrue(second.__isMask);
	}

	private static function createAnimateLibrary():AnimateLibrary
	{
		var library = new AnimateLibrary("timeline-test", "timeline-test");
		library.frameRate = 24;
		library.symbols = new Map();
		library.symbolsByClassName = new Map();
		library.bitmapSymbols = [];

		var shape = new AnimateShapeSymbol();
		shape.id = 1;
		shape.commands = [];
		library.symbols.set(shape.id, shape);
		return library;
	}

	private static function addAnimateSprite(library:AnimateLibrary, id:Int, className:String, frames:Array<Array<AnimateFrameObject>>):AnimateSpriteSymbol
	{
		var sprite = new AnimateSpriteSymbol();
		sprite.id = id;
		sprite.className = className;
		for (objects in frames)
		{
			var frame = new AnimateFrame();
			frame.objects = objects;
			sprite.frames.push(frame);
		}
		library.symbols.set(id, sprite);
		return sprite;
	}

	private static function createAnimateClip(frames:Array<Array<AnimateFrameObject>>):MovieClip
	{
		var library = createAnimateLibrary();
		var clip:MovieClip = cast addAnimateSprite(library, 10, null, frames).__createObject(library);
		library.unload();
		return clip;
	}

	private static function animateObject(type:AnimateFrameObjectType, id:Int, symbol:Int, clipDepth:Int, name:String = null):AnimateFrameObject
	{
		var object = new AnimateFrameObject();
		object.type = type;
		object.id = id;
		object.symbol = symbol;
		object.depth = 1;
		object.clipDepth = clipDepth;
		object.name = name;
		return object;
	}

	private static function createSWFLiteClip(frames:Array<Array<FrameObject>>):MovieClip
	{
		var swf = new SWFLite();
		swf.frameRate = 24;

		var shape = new ShapeSymbol();
		shape.id = 1;
		shape.commands = [];
		swf.symbols.set(shape.id, shape);

		var sprite = new SpriteSymbol();
		sprite.id = 10;
		for (objects in frames)
		{
			var frame = new Frame();
			frame.objects = objects;
			sprite.frames.push(frame);
		}
		swf.symbols.set(sprite.id, sprite);

		return cast sprite.__createObject(swf);
	}

	private static function swfLiteObject(type:FrameObjectType, id:Int, symbol:Int, clipDepth:Int):FrameObject
	{
		var object = new FrameObject();
		object.type = type;
		object.id = id;
		object.symbol = symbol;
		object.depth = 1;
		object.clipDepth = clipDepth;
		return object;
	}
	#end
}

class TimelineFieldClipA extends MovieClip
{
	public var first:DisplayObject;

	public function new()
	{
		super();
	}
}

class TimelineFieldClipB extends MovieClip
{
	public var second:DisplayObject;

	public function new()
	{
		super();
	}
}
