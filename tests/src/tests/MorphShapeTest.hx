package tests;

import openfl.errors.Error;
import swf.data.SWFMatrix;
import swf.data.SWFMorphFillStyle;
import swf.data.SWFMorphFocalGradient;
import swf.data.SWFMorphGradientRecord;
import swf.data.SWFMorphLineStyle;
import swf.data.SWFMorphLineStyle2;
import swf.data.SWFRectangle;
import swf.data.SWFShape;
import swf.data.SWFShapeRecord;
import swf.data.SWFShapeRecordCurvedEdge;
import swf.data.SWFShapeRecordStraightEdge;
import swf.data.SWFShapeRecordStyleChange;
import swf.exporters.ShapeCommandExporter;
import swf.tags.TagDefineMorphShape;
import utest.Assert;
import utest.Test;

class MorphShapeTest extends Test
{
	public function testMorphedEdges():Void
	{
		var tag = createMorphShape(1, 400, 800);
		Assert.equals("move 0 0, line 400 0, line 0 400, line -400 0, line 0 -400, end", describeRecords(tag.getMorphedShape(0)));
		Assert.equals("move 0 0, line 600 0, line 0 600, line -600 0, line 0 -600, end", describeRecords(tag.getMorphedShape(0.5)));
		Assert.equals("move 0 0, line 800 0, line 0 800, line -800 0, line 0 -800, end", describeRecords(tag.getMorphedShape(1)));

		var exporter = new ShapeCommandExporter(null);
		tag.exportHandler = exporter;
		tag.export(0.5);
		Assert.equals("noLine\nfill FF0000 1\nmoveTo 0 0\nlineTo 30 0\nlineTo 30 30\nlineTo 0 30\nlineTo 0 0\nendFill", ShapeBuilder.describe(exporter.commands));
	}

	public function testStyleChangeWithoutMoveKeepsPosition():Void
	{
		var tag = createMorphShape(1, 400, 800);
		tag.startEdges = new ShapeBuilder().move(0, 0, 0, 1, 0).lineTo(400, 0).style(-1, 1).lineTo(0, 400).lineTo(-400, 0).lineTo(0, -400).edges();
		Assert.equals("move 0 0, line 600 0, style, line 0 600, line -600 0, line 0 -600, end", describeRecords(tag.getMorphedShape(0.5)));
	}

	public function testEndMoveWithoutStartMove():Void
	{
		var tag = createMorphShape(1, 400, 800);
		tag.endEdges = new ShapeBuilder().move(0, 0).lineTo(800, 0).move(800, 200).lineTo(0, 600).lineTo(-800, 0).lineTo(0, -800).edges();
		Assert.equals("move 0 0, line 600 0, move 600 100, line 0 500, line -600 0, line 0 -600, end", describeRecords(tag.getMorphedShape(0.5)));
	}

	public function testStraightEdgeBecomesCurve():Void
	{
		var tag = createMorphShape(1, 400, 400);
		tag.startEdges = new ShapeBuilder().move(0, 0, 0, 1, 0).lineTo(400, 0).lineTo(0, 400).lineTo(-400, -400).edges();
		tag.endEdges = new ShapeBuilder().move(0, 0).curveTo(200, -200, 200, 200).lineTo(0, 400).lineTo(-400, -400).edges();
		Assert.equals("move 0 0, curve 200 -100 200 100, line 0 400, line -400 -400, end", describeRecords(tag.getMorphedShape(0.5)));
	}

	public function testPathsCloseAtAnyRatio():Void
	{
		// rounding each edge on its own leaves a gap where the path should close
		var tag = createMorphShape(1, 400, 400);
		tag.startEdges = new ShapeBuilder().move(0, 0, 0, 1, 0).lineTo(10, 0).lineTo(10, 20).lineTo(-20, -20).edges();
		tag.endEdges = new ShapeBuilder().move(0, 0).lineTo(11, 0).lineTo(11, 22).lineTo(-22, -22).edges();

		for (ratio in [0.25, 0.5, 0.75])
		{
			var x = 0;
			var y = 0;
			for (record in tag.getMorphedShape(ratio).records)
			{
				if (record.type == SWFShapeRecord.TYPE_STRAIGHTEDGE)
				{
					var edge:SWFShapeRecordStraightEdge = cast record;
					x += edge.deltaX;
					y += edge.deltaY;
				}
			}
			Assert.equals("0,0", x + "," + y, "ratio " + ratio);
		}
	}

	public function testMismatchedEdgesThrow():Void
	{
		var tag = createMorphShape(1, 400, 800);
		tag.endEdges = new ShapeBuilder().move(0, 0).lineTo(800, 0).lineTo(0, 800).lineTo(-800, -800).edges();
		Assert.raises(function() tag.getMorphedShape(0.5), Error);
	}

	public function testMorphedFocalGradient():Void
	{
		var morphedFill = createFocalGradientFill().getMorphedFillStyle(0.75);
		Assert.notNull(morphedFill.gradientMatrix);
		Assert.notNull(morphedFill.gradient);
		if (morphedFill.gradient == null) return;
		Assert.equals(1, morphedFill.gradient.spreadMode);
		Assert.equals(1, morphedFill.gradient.interpolationMode);
		Assert.floatEquals(0.25, morphedFill.gradient.focalPoint);
		Assert.equals(1, morphedFill.gradient.records.length);
	}

	public function testMorphedLineWithFillChangesWidth():Void
	{
		var lineStyle = new SWFMorphLineStyle2();
		lineStyle.startWidth = 20;
		lineStyle.endWidth = 60;
		lineStyle.hasFillFlag = true;
		lineStyle.fillType = new SWFMorphFillStyle();
		lineStyle.fillType.type = 0x00;
		lineStyle.fillType.startColor = 0xFF000000;
		lineStyle.fillType.endColor = 0xFFFFFFFF;
		Assert.equals(40, lineStyle.getMorphedLineStyle(0.5).width);
	}

	public function testMorphedLineWithoutFlags():Void
	{
		// DefineMorphShape line styles have no flags
		var lineStyle = new SWFMorphLineStyle();
		lineStyle.startWidth = 20;
		lineStyle.endWidth = 20;
		lineStyle.startColor = 0xFF000000;
		lineStyle.endColor = 0xFF000000;
		var morphedLine = lineStyle.getMorphedLineStyle(0.5);
		Assert.isFalse(morphedLine.hasFillFlag);
		Assert.isFalse(morphedLine.pixelHintingFlag);
		Assert.isFalse(morphedLine.noHScaleFlag);
	}

	private static function createFocalGradientFill():SWFMorphFillStyle
	{
		var record = new SWFMorphGradientRecord();
		record.startRatio = 0;
		record.endRatio = 255;
		record.startColor = 0xFFFF0000;
		record.endColor = 0xFF0000FF;

		var gradient = new SWFMorphFocalGradient();
		gradient.spreadMode = 1;
		gradient.interpolationMode = 1;
		gradient.startFocalPoint = -0.5;
		gradient.endFocalPoint = 0.5;
		gradient.records.push(record);

		var fillStyle = new SWFMorphFillStyle();
		fillStyle.type = 0x13;
		fillStyle.startGradientMatrix = new SWFMatrix();
		fillStyle.endGradientMatrix = new SWFMatrix();
		fillStyle.gradient = gradient;
		return fillStyle;
	}

	// A red square that grows from its top left corner, in twips
	public static function createMorphShape(characterId:Int, startSize:Int, endSize:Int):TagDefineMorphShape
	{
		var tag = new TagDefineMorphShape();
		tag.characterId = characterId;
		tag.startBounds = createRectangle(startSize);
		tag.endBounds = createRectangle(endSize);

		var fillStyle = new SWFMorphFillStyle();
		fillStyle.type = 0x00;
		fillStyle.startColor = 0xFFFF0000;
		fillStyle.endColor = 0xFFFF0000;
		tag.morphFillStyles.push(fillStyle);

		tag.startEdges = new ShapeBuilder().move(0, 0, 0, 1, 0).lineTo(startSize, 0).lineTo(0, startSize).lineTo(-startSize, 0).lineTo(0, -startSize).edges();
		tag.endEdges = new ShapeBuilder().move(0, 0).lineTo(endSize, 0).lineTo(0, endSize).lineTo(-endSize, 0).lineTo(0, -endSize).edges();
		return tag;
	}

	private static function createRectangle(size:Int):SWFRectangle
	{
		var rectangle = new SWFRectangle();
		rectangle.xmin = 0;
		rectangle.ymin = 0;
		rectangle.xmax = size;
		rectangle.ymax = size;
		return rectangle;
	}

	private static function describeRecords(shape:SWFShape):String
	{
		var records = [];
		for (record in shape.records)
		{
			switch (record.type)
			{
				case SWFShapeRecord.TYPE_STYLECHANGE:
					var styleChange:SWFShapeRecordStyleChange = cast record;
					records.push(styleChange.stateMoveTo ? "move " + styleChange.moveDeltaX + " " + styleChange.moveDeltaY : "style");
				case SWFShapeRecord.TYPE_STRAIGHTEDGE:
					var edge:SWFShapeRecordStraightEdge = cast record;
					records.push("line " + edge.deltaX + " " + edge.deltaY);
				case SWFShapeRecord.TYPE_CURVEDEDGE:
					var edge:SWFShapeRecordCurvedEdge = cast record;
					records.push("curve " + edge.controlDeltaX + " " + edge.controlDeltaY + " " + edge.anchorDeltaX + " " + edge.anchorDeltaY);
				default:
					records.push("end");
			}
		}
		return records.join(", ");
	}
}
