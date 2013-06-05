package com.codeazur.hxswf.data.actions.swf4
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionNot extends Action implements IAction
	{
		public static inline var CODE:Int = 0x12;
		
		public function ActionNot(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionNot]";
		}
	}
}
