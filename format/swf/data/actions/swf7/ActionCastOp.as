package com.codeazur.hxswf.data.actions.swf7
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionCastOp extends Action implements IAction
	{
		public static inline var CODE:Int = 0x2b;
		
		public function ActionCastOp(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionCastOp]";
		}
	}
}
