package swf.exporters.animate;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class AnimateFontSymbol extends AnimateSymbol
{
	public var advances:Array<Int>;
	public var ascent:Int;
	public var bold:Bool;
	public var codes:Array<Int>;
	public var descent:Int;
	public var glyphs:Array<Array<AnimateShapeCommand>>;
	public var italic:Bool;
	public var leading:Int;
	public var name:String;

	public function new()
	{
		super();
	}
}
