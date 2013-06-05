package com.codeazur.hxswf.data.actions.swf3
{
	import com.codeazur.hxswf.data.actions.*;
	import com.codeazur.hxswf.SWFData;
	
	class ActionGotoLabel extends Action implements IAction
	{
		public static inline var CODE:Int = 0x8c;
		
		public var label:String;
		
		public function ActionGotoLabel(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function parse(data:SWFData):Void {
			label = data.readString();
		}
		
		override public function publish(data:SWFData):Void {
			var body:SWFData = new SWFData();
			body.writeString(label);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionGotoLabel = new ActionGotoLabel(code, length);
			action.label = label;
			return action;
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionGotoLabel] Label: " + label;
		}
	}
}
