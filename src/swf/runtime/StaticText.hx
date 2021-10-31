package swf.runtime;

import swf.exporters.ShapeCommandExporter;
import swf.tags.TagDefineFont;
import swf.tags.TagDefineText;
import swf.tags.TagDefineText2;
import swf.SWFTimelineContainer;
import openfl.display.Shape;

class StaticText extends Shape
{
	private var data:SWFTimelineContainer;
	private var tag:TagDefineText;

	public function new(data:SWFTimelineContainer, tag:TagDefineText)
	{
		super();

		var matrix = null;
		var cacheMatrix = null;
		var tx = tag.textMatrix.matrix.tx * 0.05;
		var ty = tag.textMatrix.matrix.ty * 0.05;
		var color = 0x000000;
		var alpha = 1.0;

		for (record in tag.records)
		{
			var scale = (record.textHeight / 1024) * 0.05;

			cacheMatrix = matrix;
			matrix = tag.textMatrix.matrix.clone();
			matrix.scale(scale, scale);

			if (record.hasColor)
			{
				color = record.textColor & 0x00FFFFFF;

				if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (tag, TagDefineText2))
				{
					alpha = (record.textColor & 0xFF) / 0xFF;
				}
			}

			if (cacheMatrix != null && (record.hasColor || record.hasFont) && (!record.hasXOffset && !record.hasYOffset))
			{
				matrix.tx = cacheMatrix.tx;
				matrix.ty = cacheMatrix.ty;
			}
			else
			{
				matrix.tx = record.hasXOffset ? tx + (record.xOffset) * 0.05 : tx;
				matrix.ty = record.hasYOffset ? ty + (record.yOffset) * 0.05 : ty;
			}

			for (i in 0...record.glyphEntries.length)
			{
				graphics.lineStyle();
				graphics.beginFill(color, 1);

				renderGlyph(cast data.getCharacter(record.fontId), record.glyphEntries[i].index, matrix.a, matrix.tx, matrix.ty);

				graphics.endFill();
				matrix.tx += record.glyphEntries[i].advance * 0.05;
			}
		}
	}

	private function renderGlyph(font:TagDefineFont, character:Int, scale:Float, offsetX:Float, offsetY:Float):Void
	{
		var handler = new ShapeCommandExporter(data);
		font.export(handler, character);

		for (command in handler.commands)
		{
			switch (command)
			{
				// case BeginFill (color, alpha): graphics.beginFill (color, alpha);
				// case EndFill: graphics.endFill ();
				case LineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):
					if (thickness != null)
					{
						graphics.lineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
					}
					else
					{
						graphics.lineStyle();
					}

				case MoveTo(x, y):
					graphics.moveTo(x * scale + offsetX, y * scale + offsetY);
				case LineTo(x, y):
					graphics.lineTo(x * scale + offsetX, y * scale + offsetY);
				case CurveTo(controlX, controlY, anchorX, anchorY):
					graphics.curveTo(controlX * scale + offsetX, controlY * scale + offsetY, anchorX * scale + offsetX, anchorY * scale + offsetY);

				default:
			}
		}
	}
}
