package format.swf.lite;


import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import format.swf.lite.symbols.DynamicTextSymbol;
import format.swf.lite.symbols.FontSymbol;
import format.swf.lite.SWFLite;


class DynamicTextField extends TextField {
	
	
	public var symbol:DynamicTextSymbol;
	
	private var glyphs:Array<Shape>;
	private var swf:SWFLite;
	private var _text:String;
	
	
	public function new (swf:SWFLite, symbol:DynamicTextSymbol) {
		
		super ();
		
		this.swf = swf;
		this.symbol = symbol;
		
		width = symbol.width;
		height = symbol.height;
		
		multiline = symbol.multiline;
		wordWrap = symbol.wordWrap;
		displayAsPassword = symbol.password;
		border = symbol.border;
		selectable = symbol.selectable;
		
		var format = new TextFormat ();
		if (symbol.color != null) format.color = (symbol.color & 0x00FFFFFF);
		format.size = (symbol.fontHeight / 20);
		
		var font:FontSymbol = cast swf.symbols.get (symbol.fontID);
		
		if (font != null) {
			
			format.bold = font.bold;
			format.italic = font.italic;
			format.leading = font.leading / 20 - 4;
			//embedFonts = true;
			
		}
		
		format.font = symbol.fontName;
		
		var found = false;
		
		switch (format.font) {
			
			case "_sans", "_serif", "_typewriter", "", null:
				
				found = true;
			
			default:
				
				for (font in Font.enumerateFonts ()) {
					
					if (font.fontName == format.font) {
						
						found = true;
						break;
						
					}
					
				}
			
		}
		
		if (found) {
			
			embedFonts = true;
			
		} else {
			
			trace ("Warning: Could not find required font \"" + format.font + "\", it has not been embedded");
			
		}
		
		format.leftMargin = symbol.leftMargin / 20;
		format.rightMargin = symbol.rightMargin / 20;
		format.indent = symbol.indent / 20;
		format.leading = symbol.leading / 20 - 4;
		
		//#if (flash || html5)
		if (symbol.align == "center") format.align = TextFormatAlign.CENTER;
		else if (symbol.align == "right") format.align = TextFormatAlign.RIGHT;
		else if (symbol.align == "justify") format.align = TextFormatAlign.JUSTIFY;
		//#else
		//format.align = symbol.align;
		//#end
		
		defaultTextFormat = format;
		
		#if (cpp || neko)
		
		var plain = new EReg ("</p>", "g").replace (symbol.text, "\n");
		plain = new EReg ("<br>", "g").replace (symbol.text, "\n");
		text = new EReg ("<.*?>", "g").replace (plain, "");
		
		text = StringTools.htmlUnescape (text);
		
		#else
		
		if (symbol.html) {
			
			htmlText = symbol.text;
			
		} else {
			
			text = symbol.text;
			
		}
		
		#end
		
		//autoSize = (tag.autoSize) ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
		
	}
	
	
}