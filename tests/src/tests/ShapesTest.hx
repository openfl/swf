package tests;

import openfl.display.GraphicsStroke;
import openfl.display.GraphicsPath;
import openfl.display.GraphicsEndFill;
import openfl.display.GraphicsSolidFill;
import openfl.display.Shape;
import swf.tags.TagDefineSprite;
import swf.SWFTimelineContainer;
import openfl.utils.Assets;
import swf.SWF;
import utest.Test;
import utest.Assert;

class ShapesTest extends Test
{
	public function testRectWithFillAndStroke():Void
	{
		var bytes = Assets.getBytes("fixtures/shapes.swf");
		var swf = new SWF(bytes);
		Assert.isTrue(swf.hasSymbol("rect_fill_and_stroke"));
		var defTag = cast(swf.data.getCharacter(swf.symbols.get("rect_fill_and_stroke")), TagDefineSprite);
		Assert.notNull(defTag);
		var mc = new swf.runtime.MovieClip(defTag);
		Assert.notNull(mc);
		mc.gotoAndStop(1);
		#if flash
		Assert.isTrue(mc.width == 152.0);
		#else
		Assert.isTrue(mc.width == 153.0);
		#end
		Assert.equals(102.0, mc.height);
		Assert.equals(1, mc.numChildren);
		Assert.isOfType(mc.getChildAt(0), Shape);
		var child = cast(mc.getChildAt(0), Shape);
		var graphicsData = child.graphics.readGraphicsData(false);
		Assert.notNull(graphicsData);
		Assert.isTrue(graphicsData.length > 0);
	}
}
