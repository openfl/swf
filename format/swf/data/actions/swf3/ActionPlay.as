package format.swf.data.actions.swf3
{
	import format.swf.data.actions.*;
	import com.codeazur.hxswf.SWFData;
	
	class ActionPlay extends Action implements IAction
	{
		public static inline var CODE:Int = 0x06;
		
		public function ActionPlay(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionPlay]";
		}
	}
}
