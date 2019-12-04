package swf.tags;

import swf.SWFData;
import swf.data.SWFRectangle;
import swf.data.SWFShapeWithStyle;
import swf.exporters.core.IShapeExporter;
import openfl.errors.Error;

class TagDefineShape implements IDefinitionTag
{
	public static inline var TYPE:Int = 2;

	public var type(default, null):Int;
	public var name(default, null):String;
	public var version(default, null):Int;
	public var level(default, null):Int;
	public var shapeBounds:SWFRectangle;
	public var shapes:SWFShapeWithStyle;
	public var characterId:Int;

	public function new()
	{
		type = TYPE;
		name = "DefineShape";
		version = 1;
		level = 1;
	}

	public function parse(data:SWFData, length:Int, version:Int, async:Bool = false):Void
	{
		characterId = data.readUI16();
		shapeBounds = data.readRECT();
		shapes = data.readSHAPEWITHSTYLE(level);
	}

	public function publish(data:SWFData, version:Int):Void
	{
		var body:SWFData = new SWFData();
		body.writeUI16(characterId);
		body.writeRECT(shapeBounds);
		body.writeSHAPEWITHSTYLE(shapes, level);
		data.writeTagHeader(type, body.length);
		data.writeBytes(body);
	}

	public function clone():IDefinitionTag
	{
		var tag:TagDefineShape = new TagDefineShape();
		throw(new Error("Not implemented yet."));
		return tag;
	}

	public function export(handler:IShapeExporter = null):Void
	{
		shapes.export(handler);
	}

	public function toString(indent:Int = 0):String
	{
		var str:String = Tag.toStringCommon(type, name, indent) + "ID: " + characterId + ", " + "Bounds: " + shapeBounds;
		str += shapes.toString(indent + 2);
		return str;
	}
}
