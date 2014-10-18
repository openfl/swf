package format.swf.lite.symbols;


class StaticTextSymbol extends SWFSymbol {
	
	
	public var color:Null<Int>;
	public var fontHeight:Float;
	public var fontID:Int;
	public var text:String;
	
	
	public function new () {
		
		super ();
		
		type = "statictext";
		
	}
	
	
	public override function parse (data:Dynamic):Void {
		
		super.parse (data);
		
		color = data.color;
		fontHeight = data.fontHeight;
		fontID = data.fontID;
		text = data.text;
		
	}
	
	
}