package com.codeazur.hxswf.data.actions.swf4
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionMBStringLength extends Action implements IAction
	{
		public static inline var CODE:Int = 0x31;
		
		public function ActionMBStringLength(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionMBStringLength]";
		}
	}
}
