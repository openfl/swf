package com.codeazur.hxswf.data.actions.swf7
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionExtends extends Action implements IAction
	{
		public static inline var CODE:Int = 0x69;
		
		public function ActionExtends(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionExtends]";
		}
	}
}
