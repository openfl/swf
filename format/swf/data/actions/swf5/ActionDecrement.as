package com.codeazur.hxswf.data.actions.swf5
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionDecrement extends Action implements IAction
	{
		public static inline var CODE:Int = 0x51;
		
		public function ActionDecrement(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionDecrement]";
		}
	}
}
