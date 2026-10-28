package tests;

import openfl.display.Shape;
import swf.exporters.ShapeCommandExporter;
import swf.exporters.core.ShapeCommand;
import swf.exporters.swflite.SWFLite;
import swf.exporters.swflite.ShapeSymbol;
import swf.tags.TagDefineMorphShape;
import swf.tags.TagDefineShape;
import utest.Assert;
import utest.Test;

#if !flash
@:access(openfl.display.Graphics)
@:access(openfl.display._internal.DrawCommandBuffer)
#end
@:access(swf.exporters.swflite.ShapeSymbol)
class ShapeExportTest extends Test
{
	// Two squares that share an edge, a closed curve, and a triangle whose edges are given out of order
	public static function createComplexShape():ShapeBuilder
	{
		return new ShapeBuilder()
			.addSolidFill(0xFFFF0000)
			.addSolidFill(0xFF0000FF)
			.addLine(20, 0xFF000000)
			.move(0, 0, 0, 1, 1)
			.lineTo(1000, 0)
			.lineTo(0, 1000)
			.style(2, 1)
			.lineTo(-1000, 0)
			.style(0, 1)
			.lineTo(0, -1000)
			.move(1000, 1000, 0, 2)
			.lineTo(0, 1000)
			.lineTo(-1000, 0)
			.lineTo(0, -1000)
			.move(3000, 0, 0, 1, 0)
			.curveTo(500, 500, 500, -500)
			.lineTo(-1000, 0)
			.move(5000, 1000, 0, 2)
			.lineTo(1000, 0)
			.move(5500, 0)
			.lineTo(-500, 1000)
			.move(6000, 1000)
			.lineTo(-500, -1000);
	}

	public function testComplexShapeExport():Void
	{
		var exporter = new ShapeCommandExporter(null);
		createComplexShape().end().export(exporter);

		// recorded from the exporter before it was optimized, which must not change the output
		Assert.equals(EXPECTED_COMPLEX_SHAPE, ShapeBuilder.describe(exporter.commands));
	}

	public function testLineGradientStyleExport():Void
	{
		var exporter = new ShapeCommandExporter(null);
		createGradientLineShape().export(exporter);

		Assert.equals("line 1 000000\nlineGradient 2 0,255\nmoveTo 0 0\nlineTo 50 0", ShapeBuilder.describe(exporter.commands));
	}

	#if !flash
	public function testRuntimeShapeDrawsLineGradient():Void
	{
		var tag = new TagDefineShape();
		tag.shapes = createGradientLineShape();

		var shape = new swf.runtime.Shape(null, tag);
		Assert.isTrue(hasLineGradient(shape));
	}

	public function testRuntimeMorphShapeDrawsLineGradient():Void
	{
		var morphShape = new swf.runtime.MorphShape(null, new GradientLineMorphShape());
		morphShape.render();
		Assert.isTrue(hasLineGradient(morphShape));
	}

	public function testSWFLiteShapeDrawsLineGradient():Void
	{
		var symbol = new ShapeSymbol();
		symbol.commands = [
			LineStyle(1, 0, 1, false, null, null, null, null),
			LineGradientStyle(LINEAR, [0xFF0000, 0x0000FF], [1, 1], [0, 255], null, PAD, RGB, 0),
			MoveTo(0, 0),
			LineTo(50, 0)
		];

		var shape = symbol.__createObject(new SWFLite());
		Assert.isTrue(hasLineGradient(shape));
	}

	private static function hasLineGradient(shape:Shape):Bool
	{
		for (type in shape.graphics.__commands.types)
		{
			switch (type)
			{
				case LINE_GRADIENT_STYLE:
					return true;
				default:
			}
		}
		return false;
	}
	#end

	private static function createGradientLineShape():swf.data.SWFShapeWithStyle
	{
		return new ShapeBuilder()
			.addGradientLine(20, [0xFFFF0000, 0xFF0000FF], [0, 255])
			.move(0, 0, -1, -1, 1)
			.lineTo(1000, 0)
			.end();
	}

	private static var EXPECTED_COMPLEX_SHAPE = [
		"noLine",
		"fill FF0000 1",
		"moveTo 0 0",
		"lineTo 50 0",
		"lineTo 50 50",
		"lineTo 0 50",
		"lineTo 0 0",
		"moveTo 150 0",
		"curve 175 25 200 0",
		"lineTo 150 0",
		"endFill",
		"fill 0000FF 1",
		"moveTo 0 50",
		"lineTo 50 50",
		"lineTo 50 100",
		"lineTo 0 100",
		"lineTo 0 50",
		"moveTo 250 50",
		"lineTo 300 50",
		"lineTo 275 0",
		"lineTo 250 50",
		"endFill",
		"line 1 000000",
		"moveTo 0 0",
		"lineTo 50 0",
		"lineTo 50 50",
		"lineTo 0 50",
		"lineTo 0 0",
		"moveTo 50 50",
		"lineTo 50 100",
		"lineTo 0 100",
		"lineTo 0 50"
	].join("\n");
}

private class GradientLineMorphShape extends TagDefineMorphShape
{
	public function new()
	{
		super();
	}

	override public function export(ratio:Float = 0):Void
	{
		exportHandler.beginShape();
		exportHandler.beginLines();
		exportHandler.lineStyle(1, 0, 1);
		exportHandler.lineGradientStyle(LINEAR, [0xFF0000, 0x0000FF], [1, 1], [0, 255]);
		exportHandler.moveTo(0, 0);
		exportHandler.lineTo(50, 0);
		exportHandler.endLines();
		exportHandler.endShape();
	}
}
