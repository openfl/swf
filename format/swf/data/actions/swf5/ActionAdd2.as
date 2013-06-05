package com.codeazur.hxswf.data.actions.swf5
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionAdd2 extends Action implements IAction
	{
		public static inline var CODE:Int = 0x47;
		
		public function ActionAdd2(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionAdd2]";
		}
	}
}
