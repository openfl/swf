package tools;

import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import swf.data.SWFMatrix;
import swf.data.SWFRectangle;
import swf.exporters.AnimateLibraryExporter;
import swf.exporters.animate.AnimateLibrary;
import swf.tags.TagDefineShape;
import swf.tags.TagDefineSprite;
import swf.tags.TagEnd;
import swf.tags.TagPlaceObject2;
import swf.tags.TagRemoveObject2;
import swf.tags.TagShowFrame;
import sys.io.File;
import tests.SWFBuilder;
import tests.ShapeBuilder;
import utest.Assert;
import utest.Async;
import utest.Test;

// Exports a SWF with the Animate exporter, loads the result with AnimateLibrary, and plays it,
// so the runtime is tested with the data the exporter really writes
@:access(openfl.display.DisplayObject)
class RoundTripTest extends Test
{
	public function testTimelineRoundTrip(async:Async):Void
	{
		var sprite = new TagDefineSprite();
		sprite.characterId = 10;
		sprite.frameCount = 4;
		var frames:Array<Array<swf.tags.ITag>> = [
			// a named child
			[place(1, 1, "first")],
			// the same child, moved
			[move(1, 2000)],
			// another character at the same depth
			[remove(1), place(1, 2)],
			// a clipping character above it, with a masked child
			[clip(2, 1, 3), place(3, 2)]
		];
		for (frame in frames)
		{
			for (tag in frame)
			{
				sprite.tags.push(tag);
			}
			sprite.tags.push(new TagShowFrame());
		}
		sprite.tags.push(new TagEnd());

		var swf = new SWFBuilder().add(square(1, 400, 0xFF0000)).add(square(2, 800, 0x0000FF)).add(sprite).link(10, "RoundTripClip").parse();
		var path = AnimateLibraryExporterTest.tempPath("round-trip.zip");
		new AnimateLibraryExporter(swf, path);

		AnimateLibrary.loadFromBytes(File.getBytes(path)).onComplete(function(library)
		{
			var clip = library.getMovieClip("RoundTripClip");
			Assert.notNull(clip);
			Assert.equals(4, clip.totalFrames);

			var expected = [
				"first 20x20 at 0",
				"first 20x20 at 100",
				"40x40 at 0",
				"40x40 at 0 | 20x20 at 0 mask | 40x40 at 0 masked"
			];
			for (frame in 1...5)
			{
				clip.gotoAndStop(frame);
				Assert.equals(expected[frame - 1], describe(clip), "frame " + frame);
			}

			// rewinding rebuilds the earlier frames
			for (frame in [2, 1])
			{
				clip.gotoAndStop(frame);
				Assert.equals(expected[frame - 1], describe(clip), "frame " + frame + " after rewinding");
			}

			library.unload();
			async.done();
		}).onError(function(error)
		{
			Assert.fail("Could not load the exported library: " + error);
			async.done();
		});
	}

	private static function describe(clip:MovieClip):String
	{
		var children = [];
		for (i in 0...clip.numChildren)
		{
			var child = clip.getChildAt(i);
			var name = StringTools.startsWith(child.name, "instance") ? "" : child.name + " ";
			var flags = (child.__isMask == true ? " mask" : "") + (isMasked(child) ? " masked" : "");
			children.push(name + Math.round(child.width) + "x" + Math.round(child.height) + " at " + Math.round(child.x) + flags);
		}
		return children.join(" | ");
	}

	private static function isMasked(child:DisplayObject):Bool
	{
		#if (openfl >= "9.5.0")
		return child.mask != null || child.clippingLayer != null;
		#else
		return child.mask != null;
		#end
	}

	private static function square(id:Int, size:Int, rgb:Int):TagDefineShape
	{
		var tag = new TagDefineShape();
		tag.characterId = id;
		tag.shapeBounds = new SWFRectangle();
		tag.shapeBounds.xmin = 0;
		tag.shapeBounds.ymin = 0;
		tag.shapeBounds.xmax = size;
		tag.shapeBounds.ymax = size;
		tag.shapes = new ShapeBuilder()
			.addSolidFill(0xFF000000 | rgb)
			.move(0, 0, 0, 1, 0)
			.lineTo(size, 0)
			.lineTo(0, size)
			.lineTo(-size, 0)
			.lineTo(0, -size)
			.end();
		return tag;
	}

	private static function place(depth:Int, characterId:Int, name:String = null):TagPlaceObject2
	{
		var tag = new TagPlaceObject2();
		tag.depth = depth;
		tag.hasCharacter = true;
		tag.characterId = characterId;
		tag.hasMatrix = true;
		tag.matrix = new SWFMatrix();
		if (name != null)
		{
			tag.hasName = true;
			tag.instanceName = name;
		}
		return tag;
	}

	private static function move(depth:Int, x:Int):TagPlaceObject2
	{
		var tag = new TagPlaceObject2();
		tag.depth = depth;
		tag.hasMove = true;
		tag.hasMatrix = true;
		tag.matrix = new SWFMatrix();
		tag.matrix.translateX = x;
		return tag;
	}

	private static function clip(depth:Int, characterId:Int, clipDepth:Int):TagPlaceObject2
	{
		var tag = place(depth, characterId);
		tag.hasClipDepth = true;
		tag.clipDepth = clipDepth;
		return tag;
	}

	private static function remove(depth:Int):TagRemoveObject2
	{
		var tag = new TagRemoveObject2();
		tag.depth = depth;
		return tag;
	}
}
