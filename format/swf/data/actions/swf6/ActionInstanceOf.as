package com.codeazur.hxswf.data.actions.swf6
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionInstanceOf extends Action implements IAction
	{
		public static inline var CODE:Int = 0x54;
		
		public function ActionInstanceOf(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionInstanceOf]";
		}
	}
}
