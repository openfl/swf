package tests;

import openfl.geom.Matrix;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateShapeCommand;
import swf.exporters.animate.AnimateShapeSymbol;
import utest.Assert;
import utest.Test;

@:access(swf.exporters.animate.AnimateShapeSymbol)
class AnimateShapeSymbolTest extends Test
{
	public function testCompactCommandsRenderLikeLegacyCommands():Void
	{
		var colors = [0x123456, 0xABCDEF];
		var alphas = [1.0, 0.25];
		var ratios = [0, 255];
		var matrix = new Matrix(1, 0.25, -0.5, 2, 10, 20);

		var legacy = new AnimateShapeSymbol();
		legacy.commands = [
			BeginFill(0x102030, 0.75),
			MoveTo(1, 2),
			LineStyle(2.5, 0x405060, 0.5, true, 2, 1, 2, 3),
			LineTo(3, 4),
			CurveTo(5, 6, 7, 8),
			LineStyle(null, null, null, null, null, null, null, null),
			BeginGradientFill(0, colors, alphas, ratios, matrix, 1, 0, 0.25),
			EndFill
		];

		var compact = new AnimateShapeSymbol();
		var data:Array<Dynamic> = [
			1, 0x102030, 0.75,
			8, 20, 40,
			6, 2.5, 0x405060, 0.5, true, 2, 1, 2, 3,
			7, 60, 80,
			4, 100, 120, 140, 160,
			3,
			2, 0, colors, alphas, ratios, [1, 0.25, -0.5, 2, 200, 400], 1, 0, 0.25,
			5
		];
		compact.__setCompactCommands(data);

		var library = new AnimateLibrary("test", "test");
		var legacyShape = legacy.__createObject(library);
		var compactShape = compact.__createObject(library);
		var cachedCompactShape = compact.__createObject(library);

		Assert.same(legacyShape.graphics.readGraphicsData(false), compactShape.graphics.readGraphicsData(false));
		Assert.same(legacyShape.graphics.readGraphicsData(false), cachedCompactShape.graphics.readGraphicsData(false));
		Assert.same(legacyShape.getBounds(legacyShape), compactShape.getBounds(compactShape));
		Assert.isNull(compact.commands);
		Assert.isNull(compact.compactCommands);
	}
}
