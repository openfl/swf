package format.swf.lite.symbols;


import format.swf.exporters.core.ShapeCommand;


class FontSymbol extends SWFSymbol {
	
	
	public var advances:Array<Float>;
	public var ascent:Int;
	public var codes:Array<Int>;
	public var glyphs:Array<Array<ShapeCommand>>;
	
	
	public function new () {
		
		super ();
		
	}
	
	
}