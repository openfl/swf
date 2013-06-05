package com.codeazur.hxswf.data.actions.swf3
{
	import com.codeazur.hxswf.SWFData;
	import com.codeazur.hxswf.data.actions.*;
	
	class ActionGetURL extends Action implements IAction
	{
		public static inline var CODE:Int = 0x83;
		
		public var urlString:String;
		public var targetString:String;
		
		public function ActionGetURL(code:Int, length:Int) {
			super(code, length);
		}
		
		override public function parse(data:SWFData):Void {
			urlString = data.readString();
			targetString = data.readString();
		}
		
		override public function publish(data:SWFData):Void {
			var body:SWFData = new SWFData();
			body.writeString(urlString);
			body.writeString(targetString);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionGetURL = new ActionGetURL(code, length);
			action.urlString = urlString;
			action.targetString = targetString;
			return action;
		}
		
		override public function toString(indent:Int = 0):String {
			return "[ActionGetURL] URL: " + urlString + ", Target: " + targetString;
		}
	}
}
