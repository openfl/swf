package format.swf.lite;


import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import format.swf.lite.symbols.DynamicTextSymbol;
import format.swf.lite.symbols.FontSymbol;
import format.swf.lite.SWFLite;


class DynamicTextField extends TextField {
	
	
	private var glyphs:Array<Shape>;
	private var swf:SWFLite;
	private var symbol:DynamicTextSymbol;
	private var _text:String;
	
	
	public function new (swf:SWFLite, symbol:DynamicTextSymbol) {
		
		super ();
		
		this.swf = swf;
		this.symbol = symbol;
		
		width = symbol.width;
		height = symbol.height;
		text = symbol.text;
		selectable = symbol.selectable;
		//color = symbol.color;
		
	}
	
	
}