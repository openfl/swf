package com.codeazur.hxswf.data.actions.swf5
{
	import com.codeazur.hxswf.SWFData;
	import com.codeazur.hxswf.data.actions.*;
	import com.codeazur.utils.StringUtils;
	
	class ActionDefineFunction extends Action implements IAction
	{
		public static inline var CODE:Int = 0x9b;
		
		public var functionName:String;
		public var functionParams:Array<String>;
		public var functionBody:Array<IAction>;
		
		public function ActionDefineFunction(code:Int, length:Int) {
			super(code, length);
			functionParams = new Array<String>();
			functionBody = new Array<IAction>();
		}
		
		override public function parse(data:SWFData):Void {
			functionName = data.readString();
			var count:Int = data.readUI16();
			for (var i:Int = 0; i < count; i++) {
				functionParams.push(data.readString());
			}
			var codeSize:Int = data.readUI16();
			var bodyEndPosition:Int = data.position + codeSize;
			while (data.position < bodyEndPosition) {
				functionBody.push(data.readACTIONRECORD());
			}
		}
		
		override public function publish(data:SWFData):Void {
			var i:Int;
			var body:SWFData = new SWFData();
			body.writeString(functionName);
			body.writeUI16(functionParams.length);
			for (i = 0; i < functionParams.length; i++) {
				body.writeString(functionParams[i]);
			}
			var bodyActions:SWFData = new SWFData();
			for (i = 0; i < functionBody.length; i++) {
				bodyActions.writeACTIONRECORD(functionBody[i]);
			}
			body.writeUI16(bodyActions.length);
			body.writeBytes(bodyActions);
			write(data, body);
		}
		
		override public function clone():IAction {
			var i:Int;
			var action:ActionDefineFunction = new ActionDefineFunction(code, length);
			action.functionName = functionName;
			for (i = 0; i < functionParams.length; i++) {
				action.functionParams.push(functionParams[i]);
			}
			for (i = 0; i < functionBody.length; i++) {
				action.functionBody.push(functionBody[i].clone());
			}
			return action;
		}
		
		override public function toString(indent:Int = 0):String {
			var str:String = "[ActionDefineFunction] " + 
				((functionName == null || functionName.length == 0) ? "<anonymous>" : functionName) +
				"(" + functionParams.join(", ") + ")";
			for (var i:Int = 0; i < functionBody.length; i++) {
				if(functionBody[i]) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + functionBody[i].toString(indent + 4);
				}
			}
			return str;
		}
	}
}
