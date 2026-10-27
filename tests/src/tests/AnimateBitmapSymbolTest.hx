package tests;

import lime.graphics.Image;
import openfl.display.BitmapData;
import swf.exporters.animate.AnimateBitmapSymbol;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateShapeCommand;
import swf.exporters.animate.AnimateShapeSymbol;
import utest.Assert;
import utest.Test;

@:access(lime.utils.AssetLibrary)
@:access(openfl.display.BitmapData)
@:access(openfl.display.Graphics)
@:access(openfl.display._internal.DrawCommandBuffer)
@:access(swf.exporters.animate.AnimateBitmapSymbol)
@:access(swf.exporters.animate.AnimateLibrary)
@:access(swf.exporters.animate.AnimateShapeSymbol)
class AnimateBitmapSymbolTest extends Test
{
	// these tests read OpenFL's draw commands and BitmapData.readable, which Flash does not have
	#if !flash
	public function testHardwareBitmapCacheIsOptIn():Void
	{
		var library = createLibrary("bitmap-test");
		var symbol = addBitmap(library, 1, "bitmap.png");
		var image = library.cachedImages.get(symbol.path);

		var first = symbol.__createBitmapData(library);
		var second = symbol.__createBitmapData(library);
		Assert.notNull(first);
		Assert.notNull(second);

		#if (lime && swf_hardware_bitmap_cache)
		// a bitmap only used directly shares one BitmapData, without its CPU image
		Assert.isTrue(first == second);
		Assert.isFalse(first.readable);
		Assert.isFalse(library.cachedImages.exists(symbol.path));
		Assert.isTrue(first.image == image);
		#else
		Assert.isFalse(first == second);
		Assert.isTrue(first.readable);
		Assert.isTrue(second.readable);
		Assert.isTrue(library.cachedImages.exists(symbol.path));
		#end
	}

	public function testShapeBitmapFillsStayReadable():Void
	{
		var library = createLibrary("shape-bitmap-test");
		var bitmapSymbol = addBitmap(library, 1, "shape-bitmap.png");
		var image = library.cachedImages.get(bitmapSymbol.path);
		var shapeSymbol = addShape(library, 2, bitmapSymbol.id);

		var bitmapData:BitmapData = cast shapeSymbol.__createObject(library).graphics.__commands.o[0];
		Assert.notNull(bitmapData);
		Assert.isTrue(bitmapData.readable);

		#if (lime && swf_hardware_bitmap_cache)
		// OpenFL draws shape paths in software, so the fill keeps its pixels and is shared
		Assert.isTrue(bitmapData.image == image);
		var directBitmapData = bitmapSymbol.__createBitmapData(library);
		Assert.isTrue(directBitmapData.readable);
		Assert.isTrue(bitmapData == directBitmapData);
		Assert.isTrue(library.cachedImages.exists(bitmapSymbol.path));
		#else
		Assert.isFalse(bitmapData == bitmapSymbol.__createBitmapData(library));
		#end
	}

	public function testBitmapUsedByShapeStaysReadableWhenUsedDirectlyFirst():Void
	{
		#if (lime && swf_hardware_bitmap_cache)
		var library = createLibrary("shared-bitmap-test");
		var bitmapSymbol = addBitmap(library, 1, "shared-bitmap.png");
		var shapeSymbol = addShape(library, 2, bitmapSymbol.id);

		// done when the library loads, so the result does not depend on what is created first
		library.__markShapeBitmapsReadable();

		var directBitmapData = bitmapSymbol.__createBitmapData(library);
		Assert.isTrue(directBitmapData.readable);

		var shapeBitmapData:BitmapData = cast shapeSymbol.__createObject(library).graphics.__commands.o[0];
		Assert.isTrue(shapeBitmapData == directBitmapData);
		#else
		Assert.isTrue(true);
		#end
	}

	public function testCompactShapeBitmapsStayReadable():Void
	{
		#if (lime && swf_hardware_bitmap_cache)
		var library = createLibrary("compact-shape-bitmap-test");
		var bitmapSymbol = addBitmap(library, 1, "compact-shape-bitmap.png");

		// shapes loaded from a library keep compact commands
		var shapeSymbol = new AnimateShapeSymbol();
		shapeSymbol.id = 2;
		var data:Array<Dynamic> = [0, bitmapSymbol.id, null, true, true, 8, 0, 0, 7, 640, 0, 7, 640, 640, 7, 0, 640, 5];
		shapeSymbol.__setCompactCommands(data);
		library.symbols.set(shapeSymbol.id, shapeSymbol);

		library.__markShapeBitmapsReadable();
		Assert.isTrue(bitmapSymbol.__createBitmapData(library).readable);
		#else
		Assert.isTrue(true);
		#end
	}

	public function testMorphShapeBitmapsStayReadable():Void
	{
		#if (lime && swf_hardware_bitmap_cache)
		var library = createLibrary("morph-shape-bitmap-test");
		var bitmapSymbol = addBitmap(library, 1, "morph-shape-bitmap.png");

		var data:Array<Dynamic> = [0, bitmapSymbol.id, null, true, true, 8, 0, 0, 7, 640, 0, 7, 640, 640, 7, 0, 640, 5];
		var morphShape = library.__parseMorphShape({id: 2, ratios: [0], shapes: [data]});
		library.symbols.set(morphShape.id, morphShape);

		library.__markShapeBitmapsReadable();
		Assert.isTrue(bitmapSymbol.__createBitmapData(library).readable);
		#else
		Assert.isTrue(true);
		#end
	}

	private static function createLibrary(id:String):AnimateLibrary
	{
		var library = new AnimateLibrary(id, id);
		library.bitmapSymbols = [];
		library.symbols = new Map();
		return library;
	}

	private static function addBitmap(library:AnimateLibrary, id:Int, path:String):AnimateBitmapSymbol
	{
		var symbol = new AnimateBitmapSymbol();
		symbol.id = id;
		symbol.path = path;
		library.cachedImages.set(path, new Image(null, 0, 0, 32, 32, 0xFF336699));
		library.symbols.set(id, symbol);
		return symbol;
	}

	private static function addShape(library:AnimateLibrary, id:Int, bitmapID:Int):AnimateShapeSymbol
	{
		var symbol = new AnimateShapeSymbol();
		symbol.id = id;
		symbol.commands = [
			BeginBitmapFill(bitmapID, null, true, true),
			MoveTo(0, 0),
			LineTo(32, 0),
			LineTo(32, 32),
			LineTo(0, 32),
			EndFill
		];
		library.symbols.set(id, symbol);
		return symbol;
	}
	#end
}
