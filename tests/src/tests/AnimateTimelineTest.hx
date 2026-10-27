package tests;

import openfl.display.BlendMode;
import openfl.display.MovieClip;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateShapeSymbol;
import swf.exporters.animate.AnimateSpriteSymbol;
import swf.exporters.animate.AnimateTimeline;
import utest.Assert;
import utest.Test;

@:access(openfl.display.DisplayObject)
@:access(swf.exporters.animate.AnimateLibrary)
@:access(swf.exporters.animate.AnimateSpriteSymbol)
class AnimateTimelineTest extends Test
{
	public function testCompactTimelinePlayback():Void
	{
		var library = new AnimateLibrary("timeline-test", "timeline-test");
		library.frameRate = 30;
		library.symbols = new Map();

		var childSymbol = new AnimateShapeSymbol();
		childSymbol.id = 2;
		childSymbol.commands = [];
		library.symbols.set(childSymbol.id, childSymbol);

		var symbol = new AnimateSpriteSymbol();
		symbol.id = 1;
		var frames:Array<Dynamic> = [
			{
				label: "start",
				objects: [
					{
						type: 0,
						id: 10,
						symbol: 2,
						depth: 1,
						clipDepth: 0,
						matrix: [1, 0, 0, 1, 200, 400],
						colorTransform: [20, 20, 20, 10, 0, 0, 0, 0],
						filters: [[0, 4, 6, 2]],
						name: "compactChild",
						visible: false
					}
				]
			},
			{
				objects: [
					{
						type: 1,
						id: 10,
						symbol: 2,
						depth: 1,
						clipDepth: 0,
						matrix: [2, 0, 0, 3, 600, 800],
						visible: true
					}
				]
			},
			{
				objects: [
					{
						type: 2,
						id: 10,
						symbol: 2,
						depth: 1,
						clipDepth: 0
					}
				]
			}
		];
		symbol.__setCompactTimeline(frames, library);

		var timeline = new AnimateTimeline(library, symbol);
		var movieClip = new MovieClip();
		timeline.attachMovieClip(movieClip);

		Assert.equals(3, timeline.scenes[0].numFrames);
		Assert.equals("start", timeline.scenes[0].labels[0].name);
		Assert.equals(1, movieClip.numChildren);

		var child = movieClip.getChildAt(0);
		Assert.equals("compactChild", child.name);
		Assert.equals(10.0, child.x);
		Assert.equals(20.0, child.y);
		Assert.equals(0.5, child.alpha);
		Assert.isFalse(child.visible);
		Assert.equals(1, child.filters.length);

		timeline.enterFrame(2);
		Assert.equals(child, movieClip.getChildAt(0));
		Assert.equals(30.0, child.x);
		Assert.equals(40.0, child.y);
		Assert.equals(2.0, child.scaleX);
		Assert.equals(3.0, child.scaleY);
		Assert.equals(0.5, child.alpha);
		Assert.isTrue(child.visible);
		Assert.equals(0, child.filters.length);

		timeline.enterFrame(3);
		Assert.equals(0, movieClip.numChildren);
	}

	public function testParseSpriteStorage():Void
	{
		var library = createLibrary();
		var symbol = library.__parseSprite({id: 1, frames: [{objects: [createObject(0, 10, 1, 1, 0)]}]});
		#if swf_compact_animate_timelines
		Assert.notNull(symbol.compactTimeline);
		Assert.equals(0, symbol.frames.length);
		#else
		Assert.isNull(symbol.compactTimeline);
		Assert.equals(1, symbol.frames.length);
		#end
	}

	#if !flash
	public function testCompactTimelineMatchesDefault():Void
	{
		var frames:Array<Dynamic> = [
			{label: "start", objects: [createObject(0, 10, 1, 1, 0, "first", [1, 0, 0, 1, 200, 400]), createObject(0, 11, 1, 2, 3)]},
			{objects: [createObject(1, 10, 1, 1, 0, null, [2, 0, 0, 3, 600, 800], [20, 20, 20, 10, 0, 0, 0, 0], "screen")]},
			{objects: [{type: 2, id: 11}, createObject(0, 12, 1, 3, 0, "second")]},
			{objects: [{type: 2, id: 10}, {type: 2, id: 12}]}
		];

		var defaultClip = createClip(frames, false);
		var compactClip = createClip(frames, true);

		for (frame in 1...frames.length + 1)
		{
			defaultClip.gotoAndStop(frame);
			compactClip.gotoAndStop(frame);
			Assert.equals(describe(defaultClip), describe(compactClip), "frame " + frame);
		}
	}

	public function testCompactClippingCharacterWithoutTargetIsMask():Void
	{
		var clip = createClip([{objects: [createObject(0, 10, 1, 1, 5)]}], true);
		Assert.isTrue(clip.getChildAt(0).__isMask);
	}

	public function testCompactClipDepthChangeCreatesNewInstance():Void
	{
		var clip = createClip([
			{objects: [createObject(0, 10, 1, 1, 0)]},
			{objects: [{type: 2, id: 10}, createObject(0, 11, 1, 1, 3)]}
		], true);

		var first = clip.getChildAt(0);
		clip.gotoAndStop(2);
		var second = clip.getChildAt(0);
		Assert.notEquals(first, second);
		Assert.isTrue(second.__isMask);
	}

	public function testUnknownFiltersAreSkipped():Void
	{
		// an unknown filter type only drops that filter
		var object = createObject(0, 10, 1, 1, 0);
		var filters:Array<Array<Dynamic>> = [[0, 4, 6, 2], [99, 1, 2, 3], [3, 0xFF0000, 1, 6, 6, 2, 1, false, false]];
		object.filters = filters;

		for (compact in [false, true])
		{
			var filters = createClip([{objects: [object]}], compact).getChildAt(0).filters;
			Assert.equals(2, filters.length);
			Assert.isOfType(filters[0], openfl.filters.BlurFilter);
			Assert.isOfType(filters[1], openfl.filters.GlowFilter);
		}
	}

	private static function createClip(frames:Array<Dynamic>, compact:Bool):MovieClip
	{
		var library = createLibrary();
		var symbol:AnimateSpriteSymbol;
		if (compact)
		{
			symbol = new AnimateSpriteSymbol();
			symbol.id = 1;
			symbol.__setCompactTimeline(frames, library);
		}
		else
		{
			symbol = new AnimateSpriteSymbol();
			symbol.id = 1;
			library.__parseFrames(symbol, frames);
		}
		library.symbols.set(100, symbol);
		return cast symbol.__createObject(library);
	}

	private static function describe(clip:MovieClip):String
	{
		var children = [];
		for (i in 0...clip.numChildren)
		{
			var child = clip.getChildAt(i);
			// unnamed objects get an automatic instance name from OpenFL, which depends on creation order
			var name = StringTools.startsWith(child.name, "instance") ? "" : child.name;
			var values:Array<Dynamic> = [
				name, child.x, child.y, child.scaleX, child.scaleY, child.alpha, child.visible, child.__isMask == true, child.blendMode == BlendMode.SCREEN
			];
			children.push(values.join(","));
		}
		return children.join(" | ");
	}
	#end

	private static function createLibrary():AnimateLibrary
	{
		var library = new AnimateLibrary("compact-timeline-test", "compact-timeline-test");
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

	private static function createObject(type:Int, id:Int, symbol:Int, depth:Int, clipDepth:Int, name:String = null, matrix:Array<Float> = null,
			colorTransform:Array<Float> = null, blendMode:String = null):Dynamic
	{
		return {
			type: type,
			id: id,
			symbol: symbol,
			depth: depth,
			clipDepth: clipDepth,
			name: name,
			matrix: matrix,
			colorTransform: colorTransform,
			blendMode: blendMode
		};
	}
}
