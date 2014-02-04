package format.swf.data.actions.swf5
{
	import format.swf.data.actions.*;
	
	class ActionBitRShift extends Action implements IAction
	{
		public static inline var CODE:Int = 0x64;
		
		public function ActionBitRShift(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionBitRShift]";
		}
	}
}
