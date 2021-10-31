package swf.exporters.swflite;

import swf.exporters.swflite.SWFLite;
import openfl.display.DisplayObject;
import openfl.display.SimpleButton;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.SimpleButton)
class ButtonSymbol extends SWFSymbol
{
	public var downState:SpriteSymbol;
	public var hitState:SpriteSymbol;
	public var overState:SpriteSymbol;
	public var upState:SpriteSymbol;

	private var swf:SWFLite;

	public function new()
	{
		super();
	}

	private function __constructor(simpleButton:SimpleButton):Void
	{
		if (downState != null)
		{
			simpleButton.downState = downState.__createObject(swf);
		}

		if (hitState != null)
		{
			simpleButton.hitTestState = hitState.__createObject(swf);
		}

		if (overState != null)
		{
			simpleButton.overState = overState.__createObject(swf);
		}

		if (upState != null)
		{
			simpleButton.upState = upState.__createObject(swf);
		}
	}

	private override function __createObject(swf:SWFLite):SimpleButton
	{
		var simpleButton:SimpleButton = null;
		#if (!macro && !flash)
		SimpleButton.__constructor = __constructor;
		#end
		this.swf = swf;

		#if flash
		if (className == "flash.display.SimpleButton")
		{
			className = "flash.display.SimpleButton2";
		}
		#end

		if (className != null)
		{
			var symbolType = Type.resolveClass(className);

			if (symbolType != null)
			{
				simpleButton = Type.createInstance(symbolType, []);
			}
			else
			{
				// Log.warn ("Could not resolve class \"" + symbol.className + "\"");
			}
		}

		if (simpleButton == null)
		{
			simpleButton = #if flash new flash.display.SimpleButton.SimpleButton2() #else new SimpleButton() #end;
		}

		#if flash
		if (!#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (simpleButton, flash.display.SimpleButton.SimpleButton2))
		{
			__constructor(simpleButton);
		}
		#end

		return simpleButton;
	}

	private override function __init(swf:SWFLite):Void
	{
		#if (!macro && !flash)
		SimpleButton.__constructor = __constructor;
		#end
		this.swf = swf;
	}

	private override function __initObject(swf:SWFLite, instance:DisplayObject):Void
	{
		this.swf = swf;
		__constructor(cast instance);
	}
}
