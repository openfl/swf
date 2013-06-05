package com.codeazur.hxswf.data.actions.swf4
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionMultiply extends Action implements IAction
	{
		public static inline var CODE:Int = 0x0c;
		
		public function ActionMultiply(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionMultiply]";
		}
	}
}
