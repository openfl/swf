package swf.exporters.animate;

import openfl.display.MovieClip;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:keep class AnimateFrame
{
	public var labels:Array<String>;
	public var objects:Array<AnimateFrameObject>;
	public var script:MovieClip->Void;
	public var scriptSource:String;

	// public var scriptType:FrameScriptType;
	public function new() {}
}
