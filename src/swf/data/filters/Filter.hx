package swf.data.filters;

import swf.exporters.core.FilterType;
import swf.SWFData;
import openfl.filters.BitmapFilter;
import openfl.errors.Error;

class Filter implements IFilter
{
	public var filter(get, null):BitmapFilter;
	public var id(default, null):Int;
	public var type(get, null):FilterType;

	public function new(id:Int)
	{
		this.id = id;
	}

	private function get_filter():BitmapFilter
	{
		throw(new Error("Implement in subclasses!"));
		return null;
	}

	private function get_type():FilterType
	{
		return null;
	}

	public function parse(data:SWFData):Void
	{
		throw(new Error("Implement in subclasses!"));
	}

	public function publish(data:SWFData):Void
	{
		throw(new Error("Implement in subclasses!"));
	}

	public function clone():IFilter
	{
		throw(new Error("Implement in subclasses!"));
		return null;
	}

	public function toString(indent:Int = 0):String
	{
		return "[Filter]";
	}
}
