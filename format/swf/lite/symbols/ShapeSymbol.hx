package format.swf.lite.symbols;


import format.swf.exporters.core.ShapeCommand;


class ShapeSymbol extends SWFSymbol {
	
	
	public var commands:Array<ShapeCommand>;

	public var rendered:flash.display.Shape;
	
	
	public function new () {
		
		super ();
		
	}
	
	
}