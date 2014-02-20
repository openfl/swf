package format.swf.data.actions.swf3;

import format.swf.data.actions.IAction;

class ActionStop extends Action implements IAction
{
	public static inline var CODE:Int = 0x07;
	
	public function new (code:Int, length:Int) {
		super(code, length);
		//trace("Hello ActionStop");
	}
	
	override public function toString(indent:Int = 0):String {
		return "[ActionStop]";
	}
}

