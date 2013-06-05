package com.codeazur.hxswf.data.actions.swf7
{
	import com.codeazur.hxswf.SWFData;
	import com.codeazur.hxswf.data.SWFRegisterParam;
	import com.codeazur.hxswf.data.actions.*;
	import com.codeazur.utils.StringUtils;
	
	class ActionDefineFunction2 extends Action implements IAction
	{
		public static inline var CODE:Int = 0x8e;
		
		public var functionName:String;
		public var functionParams:Array<SWFRegisterParam>;
		public var functionBody:Array<IAction>;
		public var registerCount:Int;
		
		public var preloadParent:Bool;
		public var preloadRoot:Bool;
		public var preloadSuper:Bool;
		public var preloadArguments:Bool;
		public var preloadThis:Bool;
		public var preloadGlobal:Bool;
		public var suppressSuper:Bool;
		public var suppressArguments:Bool;
		public var suppressThis:Bool;
		
		public function ActionDefineFunction2(code:Int, length:Int) {
			super(code, length);
			functionParams = new Array<SWFRegisterParam>();
			functionBody = new Array<IAction>();
		}
		
		override public function parse(data:SWFData):Void {
			functionName = data.readString();
			var numParams:Int = data.readUI16();
			registerCount = data.readUI8();
			var flags1:Int = data.readUI8();
			preloadParent = ((flags1 & 0x80) != 0);
			preloadRoot = ((flags1 & 0x40) != 0);
			suppressSuper = ((flags1 & 0x20) != 0);
			preloadSuper = ((flags1 & 0x10) != 0);
			suppressArguments = ((flags1 & 0x08) != 0);
			preloadArguments = ((flags1 & 0x04) != 0);
			suppressThis = ((flags1 & 0x02) != 0);
			preloadThis = ((flags1 & 0x01) != 0);
			var flags2:Int = data.readUI8();
			preloadGlobal = ((flags2 & 0x01) != 0);
			for (var i:Int = 0; i < numParams; i++) {
				functionParams.push(data.readREGISTERPARAM());
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
			body.writeUI8(registerCount);
			var flags1:Int = 0;
			if (preloadParent) { flags1 |= 0x80; }
			if (preloadRoot) { flags1 |= 0x40; }
			if (suppressSuper) { flags1 |= 0x20; }
			if (preloadSuper) { flags1 |= 0x10; }
			if (suppressArguments) { flags1 |= 0x08; }
			if (preloadArguments) { flags1 |= 0x04; }
			if (suppressThis) { flags1 |= 0x02; }
			if (preloadThis) { flags1 |= 0x01; }
			body.writeUI8(flags1);
			var flags2:Int = data.readUI8();
			if (preloadGlobal) { flags2 |= 0x01; }
			body.writeUI8(flags2);
			for (i = 0; i < functionParams.length; i++) {
				body.writeREGISTERPARAM(functionParams[i]);
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
			var action:ActionDefineFunction2 = new ActionDefineFunction2(code, length);
			action.functionName = functionName;
			for (i = 0; i < functionParams.length; i++) {
				action.functionParams.push(functionParams[i]);
			}
			for (i = 0; i < functionBody.length; i++) {
				action.functionBody.push(functionBody[i].clone());
			}
			action.registerCount = registerCount;
			action.preloadParent = preloadParent;
			action.preloadRoot = preloadRoot;
			action.preloadSuper = preloadSuper;
			action.preloadArguments = preloadArguments;
			action.preloadThis = preloadThis;
			action.preloadGlobal = preloadGlobal;
			action.suppressSuper = suppressSuper;
			action.suppressArguments = suppressArguments;
			action.suppressThis = suppressThis;
			return action;
		}
		
		override public function toString(indent:Int = 0):String {
			var str:String = "[ActionDefineFunction2] " + 
				((functionName == null || functionName.length == 0) ? "<anonymous>" : functionName) +
				"(" + functionParams.join(", ") + "), ";
			var a:Array = [];
			if (preloadParent) { a.push("preloadParent"); }
			if (preloadRoot) { a.push("preloadRoot"); }
			if (preloadSuper) { a.push("preloadSuper"); }
			if (preloadArguments) { a.push("preloadArguments"); }
			if (preloadThis) { a.push("preloadThis"); }
			if (preloadGlobal) { a.push("preloadGlobal"); }
			if (suppressSuper) { a.push("suppressSuper"); }
			if (suppressArguments) { a.push("suppressArguments"); }
			if (suppressThis) { a.push("suppressThis"); }
			if (a.length == 0) { a.push("none"); }
			str += "Flags: " + a.join(",");
			for (var i:Int = 0; i < functionBody.length; i++) {
				str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + functionBody[i].toString(indent + 4);
			}
			return str;
		}
	}
}
