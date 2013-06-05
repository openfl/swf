package format.swf.data.filters;

import format.swf.SWFData;

import flash.filters.BitmapFilter;

interface IFilter
{
	var id(default, null):Int;
	var filter(get_filter, null):BitmapFilter;
	
	function parse(data:SWFData):Void;
	function publish(data:SWFData):Void;
	function clone():IFilter;
	function toString(indent:Int = 0):String;
}