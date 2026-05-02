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
	private var resolvedSymbolType:Class<Dynamic>;
	private var resolvedSymbolTypeReady = false;

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
		var symbolType = __resolveSymbolType();

		if (symbolType != null)
		{
			simpleButton = Type.createInstance(symbolType, []);
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

	private function __resolveSymbolType():Class<Dynamic>
	{
		if (className == null)
		{
			return null;
		}

		if (resolvedSymbolTypeReady)
		{
			return resolvedSymbolType;
		}

		var resolvedClassName = className;

		#if flash
		if (resolvedClassName == "flash.display.SimpleButton")
		{
			resolvedClassName = "flash.display.SimpleButton2";
		}
		#end

		resolvedSymbolType = Type.resolveClass(SymbolUtils.formatClassName(resolvedClassName));
		resolvedSymbolTypeReady = true;
		return resolvedSymbolType;
	}
}
