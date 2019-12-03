package format.swf.exporters.swflite;

import format.swf.exporters.swflite.SWFLite;
import openfl.display.DisplayObject;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:keepSub class SWFSymbol
{
	public var className:String;
	public var id:Int;

	public function new() {}

	private function __createObject(swf:SWFLite):DisplayObject
	{
		return null;
	}
}
