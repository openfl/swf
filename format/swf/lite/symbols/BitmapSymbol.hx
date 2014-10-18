package format.swf.lite.symbols;


class BitmapSymbol extends SWFSymbol {
	
	
	public var path:String;
	
	
	public function new () {
		
		super ();
		
		type = "bitmap";
		
	}
	
	
	public override function parse (data:Dynamic):Void {
		
		super.parse (data);
		
		path = data.path;
		
	}
	
	
}