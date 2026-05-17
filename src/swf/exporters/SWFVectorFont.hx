package swf.exporters;

typedef GlyphData =
{
	var pathData:String;
	var advance:Float;
}

typedef SWFVectorFont =
{
	var name:String;
	var ascent:Float;
	var descent:Float;
	var leading:Float;
	var glyphs:Map<Int, GlyphData>;
}
