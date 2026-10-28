package tests;

import swf.SWFData;
import swf.data.SWFShape;
import swf.data.SWFShapeRecordEnd;
import swf.tags.TagDefineFont2;
import swf.tags.TagDefineFont3;
import utest.Assert;
import utest.Test;

class TagDefineFont2Test extends Test
{
	public function testFontWithGlyphsWithoutLayout():Void
	{
		// fonts used only by static text have glyphs, but no layout
		var font = new TagDefineFont3();
		font.characterId = 1;
		font.fontName = "Test";
		font.languageCode = 0;
		font.hasLayout = false;
		font.shiftJIS = false;
		font.smallText = false;
		font.ansi = false;
		font.wideOffsets = false;
		font.wideCodes = true;
		font.italic = false;
		font.bold = false;
		font.glyphShapeTable.push(createGlyph());
		font.codeTable.push(65);

		var data = new SWFData();
		font.publish(data, 10);

		var parsed = new TagDefineFont3();
		var end = parse(data, parsed);
		Assert.equals(end, data.position);
		Assert.equals(1, parsed.glyphShapeTable.length);
		Assert.equals(65, parsed.codeTable[0]);
	}

	public function testFontWithoutGlyphsWithLayout():Void
	{
		// Flash writes a CodeTableOffset even when there are no glyphs
		var data = createFontWithoutGlyphs(true);

		var parsed = new TagDefineFont3();
		var end = parse(data, parsed);
		Assert.equals(end, data.position);
		Assert.equals(0, parsed.glyphShapeTable.length);
		Assert.equals(1000, parsed.ascent);
		Assert.equals(200, parsed.descent);
		Assert.equals(50, parsed.leading);
	}

	public function testFontWithoutGlyphsWithoutLayout():Void
	{
		var data = createFontWithoutGlyphs(false);

		var parsed = new TagDefineFont2();
		var end = parse(data, parsed);
		Assert.equals(end, data.position);
		Assert.equals("Test", parsed.fontName);
	}

	private static function parse(data:SWFData, font:TagDefineFont2):Int
	{
		data.position = 0;
		var header = data.readTagHeader();
		var end = data.position + header.contentLength;
		font.parse(data, header.contentLength, 10);
		return end;
	}

	private static function createFontWithoutGlyphs(hasLayout:Bool):SWFData
	{
		var body = new SWFData();
		body.writeUI16(1);
		body.writeUI8(hasLayout ? 0x84 : 0x04);
		body.writeLANGCODE(0);
		body.writeUI8(4);
		body.writeUTFBytes("Test");
		body.writeUI16(0);
		body.writeUI16(4); // CodeTableOffset
		if (hasLayout)
		{
			body.writeUI16(1000);
			body.writeUI16(200);
			body.writeSI16(50);
			body.writeUI16(0);
		}

		var data = new SWFData();
		data.writeTagHeader(hasLayout ? TagDefineFont3.TYPE : TagDefineFont2.TYPE, body.length);
		data.writeBytes(body);
		return data;
	}

	private static function createGlyph():SWFShape
	{
		// an empty outline, the glyph contents do not matter here
		var shape = new SWFShape();
		shape.records.push(new SWFShapeRecordEnd());
		return shape;
	}
}
