package com.codeazur.hxswf.data.actions.swf4
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionDivide extends Action implements IAction
	{
		public static inline var CODE:Int = 0x0d;
		
		public function ActionDivide(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionDivide]";
		}
	}
}
