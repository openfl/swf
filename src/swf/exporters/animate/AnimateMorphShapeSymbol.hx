package swf.exporters.animate;

import openfl.display.Shape;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(swf.exporters.animate.AnimateShapeSymbol)
class AnimateMorphShapeSymbol extends AnimateSymbol
{
	// The exporter draws the shape at each ratio the timelines use, from 0 to 65535
	public var ratios:Array<Int>;
	public var shapes:Array<AnimateShapeSymbol>;

	public function new()
	{
		super();
	}

	private override function __createObject(library:AnimateLibrary):Shape
	{
		var shape = new Shape();
		__setRatio(shape, 0, library);
		return shape;
	}

	private function __setRatio(shape:Shape, ratio:Int, library:AnimateLibrary):Void
	{
		if (ratios == null || ratios.length == 0) return;

		var index = 0;
		for (i in 1...ratios.length)
		{
			if (Math.abs(ratios[i] - ratio) < Math.abs(ratios[index] - ratio))
			{
				index = i;
			}
		}

		shape.graphics.clear();
		shape.graphics.copyFrom(shapes[index].__getRendered(library).graphics);
	}
}
