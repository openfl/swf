package tests;

import lime.graphics.Image;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import swf.exporters.animate.AnimateBitmapSymbol;
import swf.exporters.animate.AnimateFrame;
import swf.exporters.animate.AnimateFrameObject;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateShapeCommand;
import swf.exporters.animate.AnimateShapeSymbol;
import swf.exporters.animate.AnimateSpriteSymbol;
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
	public function testHardwareBitmapCacheIsOptIn():Void
	{
		var library = new AnimateLibrary("bitmap-test", "bitmap-test");
		library.bitmapSymbols = [];
		var image = new Image(null, 0, 0, 32, 32, 0xFF336699);
		var symbol = new AnimateBitmapSymbol();
		symbol.id = 1;
		symbol.path = "bitmap.png";
		library.cachedImages.set(symbol.path, image);

		var first = symbol.__createBitmapData(library);
		var second = symbol.__createBitmapData(library);

		Assert.notNull(first);
		Assert.notNull(second);

		#if (lime && !flash && swf_hardware_bitmap_cache)
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

	public function testHardwareCompatibleShapeBitmapFillsUseHardwareCache():Void
	{
		var library = new AnimateLibrary("shape-bitmap-test", "shape-bitmap-test");
		library.bitmapSymbols = [];
		library.symbols = new Map();
		var image = new Image(null, 0, 0, 32, 32, 0xFF336699);
		var bitmapSymbol = new AnimateBitmapSymbol();
		bitmapSymbol.id = 1;
		bitmapSymbol.path = "shape-bitmap.png";
		library.cachedImages.set(bitmapSymbol.path, image);
		library.symbols.set(bitmapSymbol.id, bitmapSymbol);

		var shapeSymbol = new AnimateShapeSymbol();
		shapeSymbol.commands = [
			BeginBitmapFill(bitmapSymbol.id, null, true, true),
			MoveTo(0, 0),
			LineTo(32, 0),
			LineTo(32, 32),
			LineTo(0, 32),
			EndFill
		];

		var shape = shapeSymbol.__createObject(library);
		var bitmapData:BitmapData = cast shape.graphics.__commands.o[0];
		Assert.notNull(bitmapData);

		#if (lime && !flash && swf_hardware_bitmap_cache)
		Assert.isFalse(bitmapData.readable);
		var secondShape = shapeSymbol.__createObject(library);
		var secondShapeBitmapData:BitmapData = cast secondShape.graphics.__commands.o[0];
		Assert.isTrue(bitmapData == secondShapeBitmapData);

		var directBitmapData = bitmapSymbol.__createBitmapData(library);
		Assert.isFalse(directBitmapData.readable);
		Assert.isTrue(bitmapData == directBitmapData);
		Assert.isFalse(library.cachedImages.exists(bitmapSymbol.path));
		#else
		Assert.isTrue(bitmapData.readable);
		Assert.isFalse(bitmapData == bitmapSymbol.__createBitmapData(library));
		Assert.isTrue(library.cachedImages.exists(bitmapSymbol.path));
		#end
	}

	public function testSoftwareShapeBitmapFillsStayReadableAndShared():Void
	{
		var library = new AnimateLibrary("software-shape-bitmap-test", "software-shape-bitmap-test");
		library.bitmapSymbols = [];
		library.symbols = new Map();
		var image = new Image(null, 0, 0, 32, 32, 0xFF336699);
		var bitmapSymbol = new AnimateBitmapSymbol();
		bitmapSymbol.id = 1;
		bitmapSymbol.path = "software-shape-bitmap.png";
		library.cachedImages.set(bitmapSymbol.path, image);
		library.symbols.set(bitmapSymbol.id, bitmapSymbol);

		var shapeSymbol = new AnimateShapeSymbol();
		shapeSymbol.commands = [
			BeginBitmapFill(bitmapSymbol.id, null, true, true),
			MoveTo(0, 0),
			LineTo(32, 0),
			LineTo(32, 32),
			LineTo(0, 32),
			EndFill,
			BeginGradientFill(0, [0x000000, 0xFFFFFF], [1.0, 1.0], [0, 255], null, 0, 0, 0),
			MoveTo(0, 0),
			LineTo(1, 0),
			LineTo(1, 1),
			LineTo(0, 1),
			EndFill
		];

		var shape = shapeSymbol.__createObject(library);
		var bitmapData:BitmapData = cast shape.graphics.__commands.o[0];
		Assert.notNull(bitmapData);

		#if (lime && !flash && swf_hardware_bitmap_cache)
		Assert.isTrue(bitmapData.readable);
		var secondShape = shapeSymbol.__createObject(library);
		var secondShapeBitmapData:BitmapData = cast secondShape.graphics.__commands.o[0];
		Assert.isTrue(bitmapData == secondShapeBitmapData);
		Assert.isTrue(bitmapData.image == image);

		var directBitmapData = bitmapSymbol.__createBitmapData(library);
		Assert.isFalse(directBitmapData.readable);
		Assert.isFalse(bitmapData == directBitmapData);
		Assert.isFalse(library.cachedImages.exists(bitmapSymbol.path));
		#else
		Assert.isTrue(bitmapData.readable);
		#end
	}

	public function testScale9GridShapeBitmapFillsStayReadable():Void
	{
		#if (lime && !flash && swf_hardware_bitmap_cache)
		var library = new AnimateLibrary("scale9-shape-bitmap-test", "scale9-shape-bitmap-test");
		library.bitmapSymbols = [];
		library.symbols = new Map();
		var image = new Image(null, 0, 0, 32, 32, 0xFF336699);
		var bitmapSymbol = new AnimateBitmapSymbol();
		bitmapSymbol.id = 1;
		bitmapSymbol.path = "scale9-shape-bitmap.png";
		library.cachedImages.set(bitmapSymbol.path, image);
		library.symbols.set(bitmapSymbol.id, bitmapSymbol);

		var shapeSymbol = new AnimateShapeSymbol();
		shapeSymbol.id = 2;
		shapeSymbol.commands = [
			BeginBitmapFill(bitmapSymbol.id, null, true, true),
			MoveTo(0, 0),
			LineTo(32, 0),
			LineTo(32, 32),
			LineTo(0, 32),
			EndFill
		];
		library.symbols.set(shapeSymbol.id, shapeSymbol);

		var frameObject = new AnimateFrameObject();
		frameObject.symbol = shapeSymbol.id;
		var frame = new AnimateFrame();
		frame.objects = [frameObject];
		var spriteSymbol = new AnimateSpriteSymbol();
		spriteSymbol.id = 3;
		spriteSymbol.scale9Grid = new Rectangle(8, 8, 16, 16);
		spriteSymbol.frames = [frame];
		library.symbols.set(spriteSymbol.id, spriteSymbol);

		library.__markScale9GridShapesReadable();
		var shape = shapeSymbol.__createObject(library);
		var bitmapData:BitmapData = cast shape.graphics.__commands.o[0];

		Assert.isTrue(bitmapData.readable);
		Assert.isTrue(bitmapData.image == image);
		#else
		Assert.isTrue(true);
		#end
	}
}
