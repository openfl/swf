package swf.exporters.swflite;

import swf.exporters.swflite.SWFLite;
import openfl.display.DisplayObject;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:keepSub class SWFSymbol
{
	public var className:String;
	public var id:Int;
	public var instanceProperties:Dynamic;

	public function new() {}

	function __applyInstanceProperties(instance:DisplayObject):Void
	{
		if (instance == null || instanceProperties == null)
		{
			return;
		}

		for (field in Reflect.fields(instanceProperties))
		{
			var value = __cloneInstanceProperty(Reflect.field(instanceProperties, field));
			try
			{
				Reflect.setField(instance, field, value);
			}
			catch (_:Dynamic)
			{
				try
				{
					Reflect.setProperty(instance, field, value);
				}
				catch (_:Dynamic) {}
			}
		}
	}

	private function __cloneInstanceProperty(value:Dynamic):Dynamic
	{
		if (value == null || Std.isOfType(value, Bool) || Std.isOfType(value, String) || Std.isOfType(value, Int) || Std.isOfType(value, Float))
		{
			return value;
		}

		if (Std.isOfType(value, Array))
		{
			var copy = [];
			for (item in cast(value, Array<Dynamic>))
			{
				copy.push(__cloneInstanceProperty(item));
			}
			return copy;
		}

		var clone:Dynamic = {};
		for (field in Reflect.fields(value))
		{
			Reflect.setField(clone, field, __cloneInstanceProperty(Reflect.field(value, field)));
		}
		return clone;
	}

	private function __createObject(swf:SWFLite):DisplayObject
	{
		return null;
	}

	private function __init(swf:SWFLite):Void {}

	private function __initObject(swf:SWFLite, instance:DisplayObject):Void {}
}
