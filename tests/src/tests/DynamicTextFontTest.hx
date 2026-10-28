package tests;

import openfl.text.Font;
import openfl.text.TextField;
import swf.exporters.animate.AnimateDynamicTextSymbol;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.swflite.DynamicTextSymbol;
import swf.exporters.swflite.SWFLite;
import utest.Assert;
import utest.Test;

@:access(swf.exporters.animate.AnimateDynamicTextSymbol)
@:access(swf.exporters.animate.AnimateLibrary)
@:access(swf.exporters.swflite.DynamicTextSymbol)
class DynamicTextFontTest extends Test
{
	// Flash fonts cannot be created and named at runtime
	#if !flash
	public function testAnimateFontRegisteredLater():Void
	{
		checkFontRegisteredLater("SwfTestAnimateLate", createAnimateTextField);
	}

	public function testSWFLiteFontRegisteredLater():Void
	{
		checkFontRegisteredLater("SwfTestSWFLiteLate", createSWFLiteTextField);
	}

	public function testAnimateFontMatching():Void
	{
		checkFontMatching("SwfTestAnimateFuzzy", createAnimateTextField);
	}

	public function testSWFLiteFontMatching():Void
	{
		checkFontMatching("SwfTestSWFLiteFuzzy", createSWFLiteTextField);
	}

	private static function checkFontRegisteredLater(fontName:String, createTextField:String->(Void->TextField)):Void
	{
		var create = createTextField(fontName);
		Assert.isFalse(create().embedFonts);

		// the font found for a symbol is cached, until another font is registered
		Font.registerFont(new Font(fontName));
		var textField = create();
		Assert.isTrue(textField.embedFonts);
		Assert.equals(fontName, textField.defaultTextFormat.font);
	}

	private static function checkFontMatching(fontName:String, createTextField:String->(Void->TextField)):Void
	{
		// a font name can match the start of an embedded font name, ignoring other characters
		Font.registerFont(new Font(fontName + "-Bold"));
		var create = createTextField(fontName);

		for (i in 0...2)
		{
			var textField = create();
			Assert.isTrue(textField.embedFonts);
			Assert.equals(fontName + "-Bold", textField.defaultTextFormat.font);
		}
	}

	private static function createAnimateTextField(fontName:String):Void->TextField
	{
		var library = new AnimateLibrary("dynamic-text-font-test", "dynamic-text-font-test");
		library.symbols = new Map();

		var symbol = new AnimateDynamicTextSymbol();
		symbol.fontName = fontName;
		symbol.fontHeight = 240;
		symbol.fontID = 0;
		symbol.width = symbol.height = symbol.x = symbol.y = 0;
		symbol.border = symbol.html = symbol.input = symbol.multiline = symbol.password = symbol.wordWrap = false;
		symbol.selectable = true;
		return function() return symbol.__createObject(library);
	}

	private static function createSWFLiteTextField(fontName:String):Void->TextField
	{
		var swf = new SWFLite();

		var symbol = new DynamicTextSymbol();
		symbol.fontName = fontName;
		symbol.fontHeight = 240;
		symbol.fontID = 0;
		symbol.width = symbol.height = symbol.x = symbol.y = 0;
		symbol.border = symbol.html = symbol.input = symbol.multiline = symbol.password = symbol.wordWrap = false;
		symbol.selectable = true;
		return function() return symbol.__createObject(swf);
	}
	#end
}
