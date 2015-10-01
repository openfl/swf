package format.swf.lite.symbols;


import format.swf.lite.timeline.Frame;


class SpriteSymbol extends SWFSymbol {
	
	
	public var frames:Array<Frame>;
	
	
	public function new () {
		
		super ();
		
		frames = new Array<Frame> ();
		
	}
	
	
}