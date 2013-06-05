package com.codeazur.hxswf.data.actions.swf6
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionStringGreater extends Action implements IAction
	{
		public static inline var CODE:Int = 0x68;
		
		public function ActionStringGreater(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionStringGreater]";
		}
	}
}
