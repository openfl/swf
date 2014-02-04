package format.swf.data.actions.swf5
{
	import format.swf.data.actions.*;
	
	class ActionCallMethod extends Action implements IAction
	{
		public static inline var CODE:Int = 0x52;
		
		public function ActionCallMethod(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionCallMethod]";
		}
	}
}
