package swf.runtime;

import swf.exporters.ShapeCommandExporter;
import swf.tags.TagDefineShape;
import swf.SWFTimelineContainer;

class Shape extends openfl.display.Shape
{
	public function new(data:SWFTimelineContainer, tag:TagDefineShape)
	{
		super();

		if (tag != null)
		{
			var handler = new ShapeCommandExporter(data);
			tag.export(handler);

			for (command in handler.commands)
			{
				switch (command)
				{
					case BeginFill(color, alpha):
						graphics.beginFill(color, alpha);

					case BeginBitmapFill(bitmapID, matrix, repeat, smooth):
						var bitmap = new Bitmap(cast data.getCharacter(bitmapID));

						if (bitmap.bitmapData != null)
						{
							graphics.beginBitmapFill(bitmap.bitmapData, matrix, repeat, smooth);
						}

					case BeginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio):
						graphics.beginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);

					case CurveTo(controlX, controlY, anchorX, anchorY):
						graphics.curveTo(controlX, controlY, anchorX, anchorY);

					case EndFill:
						graphics.endFill();

					case LineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):
						if (thickness != null)
						{
							graphics.lineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
						}
						else
						{
							graphics.lineStyle();
						}

					case LineTo(x, y):
						graphics.lineTo(x, y);

					case MoveTo(x, y):
						graphics.moveTo(x, y);
				}
			}
		}
	}
}
