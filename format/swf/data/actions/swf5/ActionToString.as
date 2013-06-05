package com.codeazur.hxswf.data.actions.swf5
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionToString extends Action implements IAction
	{
		public static inline var CODE:Int = 0x4b;
		
		public function ActionToString(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionToString]";
		}
	}
}
