package tests;

import openfl.display.MovieClip;
import openfl.geom.Rectangle;
import swf.exporters.animate.AnimateFrame;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateSpriteSymbol;
import swf.exporters.animate.AnimateSymbol;
import utest.Assert;
import utest.Test;

@:access(swf.exporters.animate)
class AnimateGeneratedClassTest extends Test
{
	#if !flash
	public function testGeneratedClassInitializesFromInstantiatingLibrary():Void
	{
		var libraryA = createLibrary(GeneratedTestClip.UUID, new Rectangle(1, 2, 3, 4));
		var libraryB = createLibrary("generated-class-test-b", new Rectangle(5, 6, 7, 8));

		// both libraries export the same class, which was generated for library A
		var clipB:MovieClip = cast libraryB.symbols.get(1).__createObject(libraryB);
		Assert.equals(Type.getClassName(GeneratedTestClip), Type.getClassName(Type.getClass(clipB)));
		Assert.same(new Rectangle(5, 6, 7, 8), clipB.scale9Grid);

		var clipA:MovieClip = cast libraryA.symbols.get(1).__createObject(libraryA);
		Assert.same(new Rectangle(1, 2, 3, 4), clipA.scale9Grid);

		// created without a library, the generated class uses its own library
		var clip = new GeneratedTestClip();
		Assert.same(new Rectangle(1, 2, 3, 4), clip.scale9Grid);
		Assert.isNull(AnimateSymbol.__pendingSymbol);
	}
	#end

	private static function createLibrary(uuid:String, scale9Grid:Rectangle):AnimateLibrary
	{
		var symbol = new AnimateSpriteSymbol();
		symbol.id = 1;
		symbol.className = Type.getClassName(GeneratedTestClip);
		symbol.frames.push(new AnimateFrame());
		symbol.scale9Grid = scale9Grid;

		var library = new AnimateLibrary(uuid, uuid);
		library.frameRate = 24;
		library.symbols = new Map();
		library.symbols.set(symbol.id, symbol);
		return library;
	}
}
