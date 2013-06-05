package com.codeazur.hxswf.data.actions.swf6
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionStrictEquals extends Action implements IAction
	{
		public static inline var CODE:Int = 0x66;
		
		public function ActionStrictEquals(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionStrictEquals]";
		}
	}
}
