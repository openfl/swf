package com.codeazur.hxswf.data.actions.swf4
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionSetTarget2 extends Action implements IAction
	{
		public static inline var CODE:Int = 0x20;
		
		public function ActionSetTarget2(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionSetTarget2]";
		}
	}
}
