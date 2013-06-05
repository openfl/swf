package format.swf.data.actions;

import format.swf.SWFData;
import flash.errors.Error;

class Action implements IAction
{
	public var code (default, null):Int;
	public var length(default, null):Int;
	
	public function new(code:Int, length:Int) {
		this.code = code;
		this.length = length;
	}

	public function parse(data:SWFData):Void {
		// Do nothing. Many Actions don't have a payload. 
		// For the ones that have one we override this method.
	}
	
	public function publish(data:SWFData):Void {
		write(data);
	}
	
	public function clone():IAction {
		return new Action(code, length);
	}
	
	private function write(data:SWFData, body:SWFData = null):Void {
		data.writeUI8(code);
		if (code >= 0x80) {
			if (body != null && body.length > 0) {
				length = body.length;
				data.writeUI16(length);
				data.writeBytes(body);
			} else {
				length = 0;
				throw(new Error("Action body null or empty."));
			}
		} else {
			length = 0;
		}
	}
	
	public function toString(indent:Int = 0):String {
		return "[Action] Code: " + StringTools.hex (code) + ", Length: " + length;
	}
}