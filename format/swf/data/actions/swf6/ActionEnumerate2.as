package com.codeazur.hxswf.data.actions.swf6
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionEnumerate2 extends Action implements IAction
	{
		public static inline var CODE:Int = 0x55;
		
		public function ActionEnumerate2(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionEnumerate2]";
		}
	}
}
