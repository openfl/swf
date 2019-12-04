package swf.data.actions.swf5
{
	import swf.data.actions.*;

	class ActionModulo extends Action implements IAction
	{
		public static inline var CODE:Int = 0x3f;

		public function ActionModulo(code:Int, length:Int, pos:Int) {
			super(code, length, pos);
		}

		override public function toString(indent:Int = 0):String {
			return "[ActionModulo]";
		}
	}
}
