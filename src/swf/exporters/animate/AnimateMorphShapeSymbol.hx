package swf.exporters.animate;

import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.GradientType;
import openfl.display.InterpolationMethod;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Shape;
import openfl.display.SpreadMethod;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(swf.exporters.animate.AnimateLibrary)
@:access(openfl.display.CapsStyle)
@:access(openfl.display.GradientType)
@:access(openfl.display.InterpolationMethod)
@:access(openfl.display.JointStyle)
@:access(openfl.display.LineScaleMode)
@:access(openfl.display.SpreadMethod)
class AnimateMorphShapeSymbol extends AnimateSymbol
{
	public var commands:Array<AnimateMorphShapeCommand> = [];
	public var rendered:Map<Int, Shape> = new Map<Int, Shape>();

	public function new()
	{
		super();
	}

	private override function __createObject(library:AnimateLibrary):Shape
	{
        return new AnimateMorphShape(this, library);
	}
}
