package format.swf.lite.symbols;


class TextSymbol extends SWFSymbol {
	
	
	public var border:Bool;
	public var color:Null<Int>;
	public var fontHeight:Float;
	public var fontID:Int;
	public var height:Float;
	public var multiline:Bool;
	public var password:Bool;
	public var selectable:Bool;
	public var text:String;
	public var width:Float;
	public var wordWrap:Bool;
	
	
	public function new () {
		
		super ();
		
		type = "text";
		
	}
	
	
	public override function parse (data:Dynamic):Void {
		
		super.parse (data);
		
		border = data.border;
		color = data.color;
		fontHeight = data.fontHeight;
		fontID = data.fontID;
		height = data.height;
		multiline = data.multiline;
		password = data.password;
		selectable = data.selectable;
		text = data.text;
		width = data.width;
		wordWrap = data.wordWrap;
		
	}
	
	
}