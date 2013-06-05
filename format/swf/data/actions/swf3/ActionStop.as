package com.codeazur.hxswf.data.actions.swf3
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionStop extends Action implements IAction
	{
		public static inline var CODE:Int = 0x07;
		
		public function ActionStop(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionStop]";
		}
	}
}
