package tests;

import lime.graphics.Image;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import swf.exporters.animate.AnimateBitmapSymbol;
import swf.exporters.animate.AnimateFrame;
import swf.exporters.animate.AnimateFrameObject;
#if (lime && !flash && swf_hardware_bitmap_cache)
import swf.exporters.animate.AnimateHardwareBitmapData;
#end
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
#if (lime && !flash && swf_hardware_bitmap_cache)
@:access(swf.exporters.animate.AnimateHardwareBitmapData)
#end
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
		Assert.isTrue(directBitmapData.readable);
		Assert.isTrue(bitmapData == directBitmapData);
		Assert.isTrue(library.cachedImages.exists(bitmapSymbol.path));
		#else
		Assert.isTrue(bitmapData.readable);
		#end
	}

	public function testBitmapSharedByHardwareAndSoftwareShapesStaysReadable():Void
	{
		#if (lime && !flash && swf_hardware_bitmap_cache)
		var library = new AnimateLibrary("shared-shape-bitmap-test", "shared-shape-bitmap-test");
		library.bitmapSymbols = [];
		library.symbols = new Map();
		var image = new Image(null, 0, 0, 32, 32, 0xFF336699);
		var bitmapSymbol = new AnimateBitmapSymbol();
		bitmapSymbol.id = 1;
		bitmapSymbol.path = "shared-shape-bitmap.png";
		library.cachedImages.set(bitmapSymbol.path, image);
		library.symbols.set(bitmapSymbol.id, bitmapSymbol);

		var hardwareShapeSymbol = new AnimateShapeSymbol();
		hardwareShapeSymbol.id = 2;
		hardwareShapeSymbol.commands = [
			BeginBitmapFill(bitmapSymbol.id, null, true, true),
			MoveTo(0, 0),
			LineTo(32, 0),
			LineTo(32, 32),
			LineTo(0, 32),
			EndFill
		];
		library.symbols.set(hardwareShapeSymbol.id, hardwareShapeSymbol);

		var softwareShapeSymbol = new AnimateShapeSymbol();
		softwareShapeSymbol.id = 3;
		softwareShapeSymbol.commands = [
			BeginBitmapFill(bitmapSymbol.id, null, true, true),
			BeginGradientFill(0, [0x000000, 0xFFFFFF], [1.0, 1.0], [0, 255], null, 0, 0, 0),
			EndFill
		];
		library.symbols.set(softwareShapeSymbol.id, softwareShapeSymbol);

		// Cache preparation must make the result independent of which shape is
		// instantiated first.
		library.__prepareBitmapCaches();

		var hardwareShape = hardwareShapeSymbol.__createObject(library);
		var hardwareBitmapData:BitmapData = cast hardwareShape.graphics.__commands.o[0];
		var softwareShape = softwareShapeSymbol.__createObject(library);
		var softwareBitmapData:BitmapData = cast softwareShape.graphics.__commands.o[0];

		Assert.isTrue(hardwareBitmapData.readable);
		Assert.isTrue(hardwareBitmapData == softwareBitmapData);
		Assert.isTrue(hardwareBitmapData.image == image);
		Assert.isTrue(library.cachedImages.exists(bitmapSymbol.path));
		#else
		Assert.isTrue(true);
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

	#if (lime && !flash && swf_hardware_bitmap_cache)
	// Where this Lime keeps the encoded images of a bundle
	private static function setEncodedImage(library:AnimateLibrary, path:String, bytes:lime.utils.Bytes):Void
	{
		var imageBytes:Map<String, lime.utils.Bytes> = Reflect.field(library, "cachedImageBytes");

		if (imageBytes != null)
		{
			imageBytes.set(path, bytes);
		}
		else
		{
			library.cachedBytes.set(path, bytes);
		}
	}
	#end

	public function testHardwareBitmapIsDecodedWhenItsTextureIsAskedFor():Void
	{
		#if (lime && !flash && swf_hardware_bitmap_cache)
		var library = new AnimateLibrary("deferred-bitmap-test", "deferred-bitmap-test");
		library.bitmapSymbols = [];
		var symbol = new AnimateBitmapSymbol();
		symbol.id = 1;
		symbol.path = "deferred.png";
		setEncodedImage(library, symbol.path, new Image(null, 0, 0, 48, 20, 0x336699FF).encode(PNG));

		var bitmapData = symbol.__createBitmapData(library);

		Assert.isTrue(#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (bitmapData, AnimateHardwareBitmapData));
		Assert.equals(48, bitmapData.width);
		Assert.equals(20, bitmapData.height);
		Assert.equals(48.0, bitmapData.rect.width);
		Assert.equals(20.0, bitmapData.rect.height);
		Assert.isFalse(bitmapData.readable);
		Assert.isNull(bitmapData.image);
		Assert.isTrue(bitmapData == symbol.__createBitmapData(library));
		Assert.isFalse(library.cachedImages.exists(symbol.path));

		// A clone made before the image is decoded decodes it for itself
		var clone = bitmapData.clone();
		Assert.isFalse(clone == bitmapData);
		Assert.isTrue(#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (clone, AnimateHardwareBitmapData));
		Assert.equals(48, clone.width);
		Assert.equals(20, clone.height);
		Assert.isFalse(clone.readable);
		cast(clone, AnimateHardwareBitmapData).__decodeImage();
		Assert.notNull(clone.image);
		Assert.isNull(bitmapData.image);

		// What getTexture does before it uploads
		cast(bitmapData, AnimateHardwareBitmapData).__decodeImage();

		Assert.notNull(bitmapData.image);
		Assert.equals(48, bitmapData.image.width);
		Assert.equals(20, bitmapData.image.height);
		Assert.equals(0x336699FF, bitmapData.image.getPixel32(5, 5, RGBA32));
		Assert.isFalse(bitmapData.readable);
		// The upload releases the image, and the library can decode it again
		Assert.isFalse(library.cachedImages.exists(symbol.path));
		Assert.notNull(library.__getEncodedImage(symbol.path));
		#else
		Assert.isTrue(true);
		#end
	}

	public function testDeferredHardwareBitmapTakesItsAlphaImage():Void
	{
		#if (lime && !flash && swf_hardware_bitmap_cache)
		var library = new AnimateLibrary("deferred-alpha-bitmap-test", "deferred-alpha-bitmap-test");
		library.bitmapSymbols = [];
		var symbol = new AnimateBitmapSymbol();
		symbol.id = 1;
		symbol.path = "deferred.jpg";
		symbol.alpha = "deferred-alpha.png";
		setEncodedImage(library, symbol.path, new Image(null, 0, 0, 24, 16, 0xFFFFFFFF).encode(JPEG, 100));
		setEncodedImage(library, symbol.alpha, new Image(null, 0, 0, 24, 16, 0x000000FF).encode(PNG));

		var bitmapData = symbol.__createBitmapData(library);

		Assert.isTrue(#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (bitmapData, AnimateHardwareBitmapData));
		Assert.equals(24, bitmapData.width);
		Assert.equals(16, bitmapData.height);
		Assert.isNull(bitmapData.image);

		cast(bitmapData, AnimateHardwareBitmapData).__decodeImage();

		// The alpha image's red channel is 0, so the pixels are transparent
		Assert.notNull(bitmapData.image);
		Assert.isTrue(bitmapData.image.transparent);
		Assert.equals(0, bitmapData.image.getPixel32(5, 5, RGBA32) & 0xFF);
		#else
		Assert.isTrue(true);
		#end
	}

	public function testHardwareBitmapWithoutEncodedImageIsDecodedAtOnce():Void
	{
		#if (lime && !flash && swf_hardware_bitmap_cache)
		var library = new AnimateLibrary("undeferred-bitmap-test", "undeferred-bitmap-test");
		library.bitmapSymbols = [];
		var symbol = new AnimateBitmapSymbol();
		symbol.id = 1;
		symbol.path = "unknown-format.bin";
		// Not a PNG or JPEG header, so its size is not known before decoding
		setEncodedImage(library, symbol.path, lime.utils.Bytes.ofString("not an image the header of which is read"));
		Assert.isNull(AnimateHardwareBitmapData.create(library, symbol));

		var png = new Image(null, 0, 0, 300, 7, 0x336699FF).encode(PNG);
		var jpeg = new Image(null, 0, 0, 300, 7, 0x336699FF).encode(JPEG, 90);
		Assert.same([300, 7], AnimateHardwareBitmapData.readSize(png));
		Assert.same([300, 7], AnimateHardwareBitmapData.readSize(jpeg));
		Assert.isNull(AnimateHardwareBitmapData.readSize(png.sub(0, 20)));
		#else
		Assert.isTrue(true);
		#end
	}
}
