package com.codeazur.hxswf.data.actions.swf5
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionModulo extends Action implements IAction
	{
		public static inline var CODE:Int = 0x3f;
		
		public function ActionModulo(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionModulo]";
		}
	}
}
