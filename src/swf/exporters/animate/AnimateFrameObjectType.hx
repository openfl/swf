package swf.exporters.animate;

#if (haxe_ver >= 4.0) enum #else @:enum #end abstract AnimateFrameObjectType(Int) from Int to Int
{
	public var CREATE = 0;
	public var UPDATE = 1;
	public var DESTROY = 2;
}
