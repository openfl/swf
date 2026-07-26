package tests;

import openfl.display.MovieClip;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateShapeSymbol;
import swf.exporters.animate.AnimateSpriteSymbol;
import swf.exporters.animate.AnimateTimeline;
import utest.Assert;
import utest.Test;

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
		symbol.__setCompactTimeline(frames);

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
}
