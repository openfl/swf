package swf.exporters.animate;

import swf.exporters.core.FilterType;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class AnimateFrameObject
{
	public var blendMode:BlendMode;
	public var cacheAsBitmap:Null<Bool>;
	public var clipDepth:Int;
	public var colorTransform:ColorTransform;
	public var depth:Int;
	public var filters:Array<FilterType>;
	public var id:Int;
	public var matrix:Matrix;
	public var name:String;
	public var symbol:Int;
	public var type:AnimateFrameObjectType;
	public var visible:Null<Bool>;
	public var ratio:Null<Int>;

	public function new() {}
}
