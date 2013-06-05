package format.swf.data.filters;

import format.swf.SWFData;

import flash.filters.BitmapFilter;
import flash.errors.Error;

class Filter implements IFilter
{
	public var filter (get_filter, null):BitmapFilter;
	public var id (default, null):Int;
	
	public function new(id:Int) {
		this.id = id;
	}

	private function get_filter():BitmapFilter {
		throw(new Error("Implement in subclasses!"));
		return null;
	}
	
	public function parse(data:SWFData):Void {
		throw(new Error("Implement in subclasses!"));
	}
	
	public function publish(data:SWFData):Void {
		throw(new Error("Implement in subclasses!"));
	}
	
	public function clone():IFilter {
		throw(new Error("Implement in subclasses!"));
		return null;
	}
	
	public function toString(indent:Int = 0):String {
		return "[Filter]";
	}
}