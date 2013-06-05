package com.codeazur.hxswf.data.actions.swf6
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionGreater extends Action implements IAction
	{
		public static inline var CODE:Int = 0x67;
		
		public function ActionGreater(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionGreater]";
		}
	}
}
