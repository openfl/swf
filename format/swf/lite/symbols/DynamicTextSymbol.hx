package format.swf.lite.symbols;


import flash.text.TextFormatAlign;


class DynamicTextSymbol extends SWFSymbol {
	
	
	public var align:/*TextFormatAlign*/String;
	public var border:Bool;
	public var color:Null<Int>;
	public var fontHeight:Int;
	public var fontID:Int;
	public var fontName:String;
	public var height:Float;
	public var indent:Int;
	public var leading:Int;
	public var leftMargin:Int;
	public var multiline:Bool;
	public var password:Bool;
	public var rightMargin:Int;
	public var selectable:Bool;
	public var text:String;
	public var width:Float;
	public var wordWrap:Bool;
	public var x:Float;
	public var y:Float;
	
	
	public function new () {
		
		super ();
		
		type = "dynamictext";
		
	}
	
	
	public override function parse (data:Dynamic):Void {
		
		super.parse (data);
		
		align = data.align;
		border = data.border;
		color = data.color;
		fontHeight = data.fontHeight;
		fontID = data.fontID;
		fontName = data.fontName;
		height = data.height;
		indent = data.indent;
		leading = data.leading;
		leftMargin = data.leftMargin;
		multiline = data.multiline;
		password = data.password;
		rightMargin = data.rightMargin;
		selectable = data.selectable;
		text = data.text;
		width = data.width;
		wordWrap = data.wordWrap;
		x = data.x;
		y = data.y;
		
	}
	
	
}