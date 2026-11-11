package tests;

import haxe.Json;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import swf.exporters.animate.AnimateLibrary;
import utest.Assert;
import utest.Test;

@:access(lime.utils.AssetLibrary)
@:access(openfl.utils.Assets)
@:access(swf.exporters.animate.AnimateLibrary)
class AnimateLibraryLoadTest extends Test
{
	private static inline var CLASS_NAME = "AnimateLibraryLoadTestClip";

	public function testLoadLetsTheTextGo():Void
	{
		var library = createLibrary("load-text-test");
		var loaded = load(library);

		Assert.isTrue(loaded);
		Assert.isFalse(library.cachedText.exists(library.id));
		Assert.isTrue(library.symbolsByClassName.exists(CLASS_NAME));
		Assert.equals(library, Assets.libraryBindings.get(CLASS_NAME));

		library.unload();
	}

	public function testLoadAgainKeepsTheSymbols():Void
	{
		var library = createLibrary("load-again-test");
		load(library);
		var symbol = library.symbols.get(1);

		Assert.isTrue(load(library));
		Assert.equals(symbol, library.symbols.get(1));

		library.unload();
	}

	public function testLoadAfterUnloadRestoresTheBindings():Void
	{
		var library = createLibrary("load-after-unload-test");
		load(library);

		library.unload();
		Assert.isFalse(Assets.libraryBindings.exists(CLASS_NAME));

		Assert.isTrue(load(library));
		Assert.equals(library, Assets.libraryBindings.get(CLASS_NAME));

		library.unload();
	}

	private static function createLibrary(name:String):AnimateLibrary
	{
		var id = name + ".json";
		var library = new AnimateLibrary(id, name);
		library.types.set(id, cast AssetType.TEXT);
		library.cachedText.set(id, Json.stringify({
			version: 0.1,
			frameRate: 30,
			root: 0,
			symbols: [{type: 5, id: 1, className: CLASS_NAME, frames: [{objects: []}]}]
		}));
		return library;
	}

	private static function load(library:AnimateLibrary):Bool
	{
		var loaded = false;
		library.load().onComplete(function(result)
		{
			loaded = result == library;
		});
		return loaded;
	}
}
