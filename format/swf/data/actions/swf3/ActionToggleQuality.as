package com.codeazur.hxswf.data.actions.swf3
{
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionToggleQuality extends Action implements IAction
	{
		public static inline var CODE:Int = 0x08;
		
		public function ActionToggleQuality(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionToggleQuality]";
		}
	}
}
