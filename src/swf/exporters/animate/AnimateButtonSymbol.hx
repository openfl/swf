package swf.exporters.animate;

import swf.utils.SymbolUtils;
import openfl.display.DisplayObject;
import openfl.display.SimpleButton;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.SimpleButton)
class AnimateButtonSymbol extends AnimateSymbol
{
	public var downState:AnimateSpriteSymbol;
	public var hitState:AnimateSpriteSymbol;
	public var overState:AnimateSpriteSymbol;
	public var upState:AnimateSpriteSymbol;

	private var library:AnimateLibrary;

	public function new()
	{
		super();
	}

	private function __constructor(simpleButton:SimpleButton):Void
	{
		if (downState != null)
		{
			simpleButton.downState = downState.__createObject(library);
		}

		if (hitState != null)
		{
			simpleButton.hitTestState = hitState.__createObject(library);
		}

		if (overState != null)
		{
			simpleButton.overState = overState.__createObject(library);
		}

		if (upState != null)
		{
			simpleButton.upState = upState.__createObject(library);
		}
	}

	private override function __createObject(library:AnimateLibrary):SimpleButton
	{
		var simpleButton:SimpleButton = null;
		SimpleButton.__constructor = __constructor;
		this.library = library;

		#if flash
		if (className == "flash.display.SimpleButton")
		{
			className = "flash.display.SimpleButton2";
		}
		#end

		if (className != null)
		{
			var symbolType = Type.resolveClass(SymbolUtils.formatClassName(className));

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

	private override function __init(library:AnimateLibrary):Void
	{
		SimpleButton.__constructor = __constructor;
		this.library = library;
	}

	private override function __initObject(library:AnimateLibrary, instance:DisplayObject):Void
	{
		this.library = library;
		__constructor(cast instance);
	}
}
