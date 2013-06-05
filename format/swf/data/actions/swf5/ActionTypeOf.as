package com.codeazur.hxswf.data.actions.swf5
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionTypeOf extends Action implements IAction
	{
		public static inline var CODE:Int = 0x44;
		
		public function ActionTypeOf(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionTypeOf]";
		}
	}
}
