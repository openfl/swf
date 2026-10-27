package swf.exporters.animate;

import openfl.display.DisplayObject;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:keepSub class AnimateSymbol
{
	// The symbol whose linkage class is being instantiated, so that a generated class
	// initializes from the library creating it, even when another library exports a
	// class with the same name
	@:noCompletion private static var __pendingLibrary:AnimateLibrary;
	@:noCompletion private static var __pendingSymbol:AnimateSymbol;
	@:noCompletion private static var __pendingType:Class<Dynamic>;

	public var className:String;
	public var id:Int;

	public function new() {}

	private function __createInstance(library:AnimateLibrary, type:Class<Dynamic>):Dynamic
	{
		var previousLibrary = __pendingLibrary;
		var previousSymbol = __pendingSymbol;
		var previousType = __pendingType;

		__pendingLibrary = library;
		__pendingSymbol = this;
		__pendingType = type;

		var instance:Dynamic = null;

		try
		{
			instance = Type.createInstance(type, []);
		}
		catch (e:Dynamic)
		{
			__pendingLibrary = previousLibrary;
			__pendingSymbol = previousSymbol;
			__pendingType = previousType;
			throw e;
		}

		__pendingLibrary = previousLibrary;
		__pendingSymbol = previousSymbol;
		__pendingType = previousType;

		return instance;
	}

	private function __createObject(library:AnimateLibrary):DisplayObject
	{
		return null;
	}

	private function __init(library:AnimateLibrary):Void {}

	// Called by generated classes before super(). Returns false if the class is not
	// being instantiated by a library, such as when it is created with "new".
	private static function __initPending(type:Class<Dynamic>):Bool
	{
		var pendingType = __pendingType;

		while (pendingType != null && pendingType != type)
		{
			pendingType = Type.getSuperClass(pendingType);
		}

		if (pendingType == null) return false;

		var library = __pendingLibrary;
		var symbol = __pendingSymbol;

		__pendingLibrary = null;
		__pendingSymbol = null;
		__pendingType = null;

		symbol.__init(library);
		return true;
	}

	private function __initObject(library:AnimateLibrary, instance:DisplayObject):Void {}
}
