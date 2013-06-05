package com.codeazur.hxswf.data.actions.swf5
{
	import com.codeazur.hxswf.SWFData;
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionStoreRegister extends Action implements IAction
	{
		public static inline var CODE:Int = 0x87;
		
		public var registerNumber:Int;
		
		public function ActionStoreRegister(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function parse(data:SWFData):Void {
			registerNumber = data.readUI8();
		}
		
		override public function publish(data:SWFData):Void {
			var body:SWFData = new SWFData();
			body.writeUI8(registerNumber);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionStoreRegister = new ActionStoreRegister(code, length);
			action.registerNumber = registerNumber;
			return action;
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionStoreRegister] RegisterNumber: " + registerNumber;
		}
	}
}
