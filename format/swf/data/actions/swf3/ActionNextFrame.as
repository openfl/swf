package com.codeazur.hxswf.data.actions.swf3
{
	import com.codeazur.hxswf.data.actions.*;
	import com.codeazur.hxswf.SWFData;
	
	class ActionNextFrame extends Action implements IAction
	{
		public static inline var CODE:Int = 0x04;
		
		public function ActionNextFrame(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionNextFrame]";
		}
	}
}
