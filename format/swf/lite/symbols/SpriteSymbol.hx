package format.swf.lite.symbols;


import format.swf.lite.timeline.FrameObject;
import format.swf.lite.timeline.Frame;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;


class SpriteSymbol extends SWFSymbol {
	
	
	public var frames:Array <Frame>;
	
	
	public function new () {
		
		super ();
		
		frames = new Array <Frame> ();
		
	}
	
	
}