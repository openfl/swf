package swf.exporters;

import swf.SWF;
import swf.tags.TagDefineFont2;
import swf.tags.TagDefineFont3;
import swf.exporters.ShapeCommandExporter;
import swf.exporters.core.ShapeCommand;
import swf.exporters.SWFVectorFont;
import sys.thread.Thread;
import sys.thread.Mutex;
import sys.thread.Lock;

class NativeFontExporter
{
	private static inline var TWIPS:Float = 20.0;

	public static function extract(swf:SWF):Array<SWFVectorFont>
	{
		var exportedFonts = new Array<SWFVectorFont>();
		var fontTagsToProcess = new Array<TagDefineFont2>();

		for (tag in swf.data.tags)
		{
			if (Std.isOfType(tag, TagDefineFont2))
			{
				fontTagsToProcess.push(cast tag);
			}
		}

		if (fontTagsToProcess.length == 0) return exportedFonts;

		var mutex = new Mutex();
		var lock = new Lock();

		for (fontTag in fontTagsToProcess)
		{
			Thread.create(function()
			{
				var parsedFont = processFontTag(fontTag);

				mutex.acquire();
				exportedFonts.push(parsedFont);
				mutex.release();
				lock.release();
			});
		}

		for (i in 0...fontTagsToProcess.length)
		{
			lock.wait();
		}

		return exportedFonts;
	}

	private static function processFontTag(fontTag:TagDefineFont2):SWFVectorFont
	{
		var isFont3 = Std.isOfType(fontTag, TagDefineFont3);
		var scale = isFont3 ? (TWIPS * 20.0) : TWIPS;

		var font:SWFVectorFont = {
			name: fontTag.fontName != null ? fontTag.fontName : "Unknown_" + fontTag.characterId,
			ascent: 0,
			descent: 0,
			leading: 0,
			glyphs: new Map<Int, GlyphData>()
		};

		if (fontTag.hasLayout)
		{
			font.ascent = roundFloat(fontTag.ascent / scale);
			font.descent = roundFloat(fontTag.descent / scale);
			font.leading = roundFloat(fontTag.leading / scale);
		}

		var shapeTable = fontTag.glyphShapeTable;
		var codeTable = fontTag.codeTable;

		if (shapeTable != null && codeTable != null)
		{
			for (i in 0...shapeTable.length)
			{
				if (i >= codeTable.length) break;

				var charCode = codeTable[i];
				var shape = shapeTable[i];

				var shapeExporter = new ShapeCommandExporter(null);
				shape.export(shapeExporter);

				var finalSvgPath = generateSVGPath(shapeExporter.commands, scale);

				var charAdvance = 0.0;
				if (fontTag.hasLayout && fontTag.fontAdvanceTable != null && i < fontTag.fontAdvanceTable.length)
				{
					charAdvance = roundFloat(fontTag.fontAdvanceTable[i] / scale);
				}

				font.glyphs.set(charCode, {
					pathData: finalSvgPath,
					advance: charAdvance
				});
			}
		}

		return font;
	}

	private static function generateSVGPath(commands:Array<ShapeCommand>, scale:Float):String
	{
		if (commands == null || commands.length == 0) return "";

		var buf = new StringBuf();
		for (cmd in commands)
		{
			switch (cmd)
			{
				case MoveTo(x, y):
					buf.add("M ");
					buf.add(roundFloat(x / scale));
					buf.add(" ");
					buf.add(roundFloat(y / scale));
					buf.add(" ");
				case LineTo(x, y):
					buf.add("L ");
					buf.add(roundFloat(x / scale));
					buf.add(" ");
					buf.add(roundFloat(y / scale));
					buf.add(" ");
				case CurveTo(cx, cy, ax, ay):
					buf.add("Q ");
					buf.add(roundFloat(cx / scale));
					buf.add(" ");
					buf.add(roundFloat(cy / scale));
					buf.add(" ");
					buf.add(roundFloat(ax / scale));
					buf.add(" ");
					buf.add(roundFloat(ay / scale));
					buf.add(" ");
				default:
			}
		}
		return StringTools.trim(buf.toString());
	}

	private static inline function roundFloat(val:Float):Float
	{
		return Math.round(val * 10000.0) / 10000.0;
	}
}
