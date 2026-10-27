package tests;

import swf.data.SWFFillStyle;
import swf.data.SWFGradient;
import swf.data.SWFGradientRecord;
import swf.data.SWFLineStyle2;
import swf.data.SWFMatrix;
import swf.data.SWFShapeRecordCurvedEdge;
import swf.data.SWFShapeRecordEnd;
import swf.data.SWFShapeRecordStraightEdge;
import swf.data.SWFShapeRecordStyleChange;
import swf.data.SWFShapeWithStyle;
import swf.exporters.core.ShapeCommand;

// Builds DefineShape4 records in code, in twips like a SWF file
class ShapeBuilder
{
	public var shape(default, null):SWFShapeWithStyle;

	public function new()
	{
		shape = new SWFShapeWithStyle(null, 4);
	}

	public function addSolidFill(argb:Int):ShapeBuilder
	{
		var fillStyle = new SWFFillStyle();
		fillStyle.type = 0x00;
		fillStyle.rgb = argb;
		shape.initialFillStyles.push(fillStyle);
		return this;
	}

	public function addLine(width:Int, argb:Int):ShapeBuilder
	{
		var lineStyle = new SWFLineStyle2(null, 4);
		lineStyle.width = width;
		lineStyle.color = argb;
		shape.initialLineStyles.push(lineStyle);
		return this;
	}

	public function addGradientLine(width:Int, colors:Array<Int>, ratios:Array<Int>):ShapeBuilder
	{
		var gradient = new SWFGradient();
		for (i in 0...colors.length)
		{
			var record = new SWFGradientRecord();
			record.color = colors[i];
			record.ratio = ratios[i];
			gradient.records.push(record);
		}

		var fillStyle = new SWFFillStyle();
		fillStyle.type = 0x10;
		fillStyle.gradient = gradient;
		fillStyle.gradientMatrix = new SWFMatrix();

		var lineStyle = new SWFLineStyle2(null, 4);
		lineStyle.width = width;
		lineStyle.hasFillFlag = true;
		lineStyle.fillType = fillStyle;
		shape.initialLineStyles.push(lineStyle);
		return this;
	}

	// fill and line style indexes start at 1, 0 clears a style and -1 leaves it unchanged
	public function move(x:Int, y:Int, fill0:Int = -1, fill1:Int = -1, line:Int = -1):ShapeBuilder
	{
		addStyleChange(true, x, y, fill0, fill1, line);
		return this;
	}

	public function style(fill0:Int = -1, fill1:Int = -1, line:Int = -1):ShapeBuilder
	{
		addStyleChange(false, 0, 0, fill0, fill1, line);
		return this;
	}

	private function addStyleChange(moveTo:Bool, x:Int, y:Int, fill0:Int, fill1:Int, line:Int):Void
	{
		var record = new SWFShapeRecordStyleChange();
		if (moveTo)
		{
			record.stateMoveTo = true;
			record.moveDeltaX = x;
			record.moveDeltaY = y;
		}
		if (fill0 >= 0)
		{
			record.stateFillStyle0 = true;
			record.fillStyle0 = fill0;
		}
		if (fill1 >= 0)
		{
			record.stateFillStyle1 = true;
			record.fillStyle1 = fill1;
		}
		if (line >= 0)
		{
			record.stateLineStyle = true;
			record.lineStyle = line;
		}
		shape.records.push(record);
	}

	public function lineTo(deltaX:Int, deltaY:Int):ShapeBuilder
	{
		var record = new SWFShapeRecordStraightEdge();
		record.generalLineFlag = true;
		record.deltaX = deltaX;
		record.deltaY = deltaY;
		shape.records.push(record);
		return this;
	}

	public function curveTo(controlDeltaX:Int, controlDeltaY:Int, anchorDeltaX:Int, anchorDeltaY:Int):ShapeBuilder
	{
		var record = new SWFShapeRecordCurvedEdge();
		record.controlDeltaX = controlDeltaX;
		record.controlDeltaY = controlDeltaY;
		record.anchorDeltaX = anchorDeltaX;
		record.anchorDeltaY = anchorDeltaY;
		shape.records.push(record);
		return this;
	}

	public function end():SWFShapeWithStyle
	{
		shape.records.push(new SWFShapeRecordEnd());
		return shape;
	}

	// A readable description of shape commands, with numbers rounded so it is the same on every target
	public static function describe(commands:Array<ShapeCommand>):String
	{
		var lines = [];
		for (command in commands)
		{
			lines.push(switch (command)
			{
				case BeginBitmapFill(bitmap, _, repeat, smooth): "bitmapFill " + bitmap + " " + repeat + " " + smooth;
				case BeginFill(color, alpha): "fill " + StringTools.hex(color, 6) + " " + number(alpha);
				case BeginGradientFill(_, colors, _, ratios, _, _, _, _): "gradientFill " + colors.length + " " + ratios.join(",");
				case CurveTo(controlX, controlY, anchorX, anchorY): "curve " + number(controlX) + " " + number(controlY) + " " + number(anchorX) + " "
					+ number(anchorY);
				case EndFill: "endFill";
				case LineStyle(thickness, color, _, _, _, _, _, _): thickness == null ? "noLine" : "line " + number(thickness) + " " + StringTools.hex(color, 6);
				case LineGradientStyle(_, colors, _, ratios, _, _, _, _): "lineGradient " + colors.length + " " + ratios.join(",");
				case LineTo(x, y): "lineTo " + number(x) + " " + number(y);
				case MoveTo(x, y): "moveTo " + number(x) + " " + number(y);
			});
		}
		return lines.join("\n");
	}

	private static function number(value:Float):String
	{
		return Std.string(Math.round(value * 100) / 100);
	}
}
