package;

import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import swf.SWF;
import openfl.utils.ByteArray;
import swf.exporters.NativeFontExporter;
import swf.exporters.SWFVectorFont;

class ExportFonts
{
	public static function main()
	{
		var args = Sys.args();
		if (args.length < 2)
		{
			Sys.println("ExportFonts - Native SWF Vector Extractor\n");
			Sys.println("Usage (Recommended - Neko):");
			Sys.println("  1. Build: haxe -cp src -cp scripts -lib openfl -lib lime -lib format -D optional-cffi -main ExportFonts -neko export_fonts.n");
			Sys.println("  2. Run:   neko export_fonts.n <input.swf> <output_folder>\n");
			Sys.println("Usage (Direct/Eval - May cause memory issues on large SWFs):");
			Sys.println("  haxe --run ExportFonts <input.swf> <output_folder>");
			return;
		}

		var swfPath = args[0];
		var outputDir = args[1];

		if (!FileSystem.exists(swfPath))
		{
			Sys.println("Error: Input SWF file not found at path: " + swfPath);
			return;
		}

		Sys.println("Reading SWF: " + swfPath);
		var rawBytes = File.getBytes(swfPath);
		var bytes = ByteArray.fromBytes(rawBytes);

		bytes.position = 0;
		bytes.endian = openfl.utils.Endian.LITTLE_ENDIAN;

		var swf = new SWF(bytes);

		Sys.println("Extracting Vector Fonts natively...");
		var fonts = NativeFontExporter.extract(swf);

		if (!FileSystem.exists(outputDir))
		{
			FileSystem.createDirectory(outputDir);
		}

		var nameCount = new Map<String, Int>();

		for (font in fonts)
		{
			var baseName = font.name.split(" ").join("_");
			var safeName = baseName;

			if (nameCount.exists(baseName))
			{
				var count = nameCount.get(baseName) + 1;
				nameCount.set(baseName, count);
				safeName = baseName + "_" + count;
			}
			else
			{
				nameCount.set(baseName, 1);
			}

			var xmlContent = generateXML(font);

			var filePath = Path.join([outputDir, safeName + ".xml"]);
			File.saveContent(filePath, xmlContent);
			Sys.println("Saved: " + filePath);
		}

		Sys.println("Done! Extracted " + fonts.length + " individual XML fonts.");
	}

	private static function generateXML(font:SWFVectorFont):String
	{
		var buf = new StringBuf();

		buf.add('<?xml version="1.0" encoding="utf-8"?>\n');
		buf.add('<font name="${font.name}" ascent="${font.ascent}" descent="${font.descent}" leading="${font.leading}">\n');

		for (charCode in font.glyphs.keys())
		{
			var glyph = font.glyphs.get(charCode);
			buf.add('\t<glyph charCode="$charCode" advance="${glyph.advance}">\n');

			if (glyph.pathData != "")
			{
				buf.add('\t\t<path d="');
				buf.add(glyph.pathData);
				buf.add('"/>\n');
			}

			buf.add('\t</glyph>\n');
		}

		buf.add('</font>');
		return buf.toString();
	}
}
