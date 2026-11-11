package swf.exporters.animate;

#if (lime && !flash && swf_hardware_bitmap_cache)
import lime.utils.Bytes;
import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.display3D.textures.TextureBase;
import openfl.geom.Rectangle;

/**
	A hardware-only bitmap of an Animate library that decodes its image when a
	texture is first asked for, and again if the texture is lost, instead of
	when a symbol that uses it is created.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.BitmapData)
@:access(openfl.display3D.Context3D)
@:access(swf.exporters.animate.AnimateLibrary)
class AnimateHardwareBitmapData extends BitmapData
{
	private var __library:AnimateLibrary;
	private var __symbol:AnimateBitmapSymbol;
	// AnimateLibrary's clock when a texture was last asked for
	private var __lastUsed:Float = 0;
	// A clone draws with this bitmap's texture without asking it for one
	private var __textureShared:Bool = false;

	private function new(library:AnimateLibrary, symbol:AnimateBitmapSymbol, width:Int, height:Int)
	{
		super(0, 0, true, 0);

		__library = library;
		__symbol = symbol;

		this.width = width;
		this.height = height;
		rect = new Rectangle(0, 0, width, height);

		__textureWidth = width;
		__textureHeight = height;

		__isValid = true;
		readable = false;
	}

	/**
		A bitmap for the symbol, or null when its size cannot be told without
		decoding it: the library does not hold its encoded image, or it is
		not a PNG or JPEG file.
	**/
	@:allow(swf.exporters.animate.AnimateLibrary)
	private static function create(library:AnimateLibrary, symbol:AnimateBitmapSymbol):AnimateHardwareBitmapData
	{
		if (symbol.path == null)
		{
			return null;
		}

		var bytes = library.__getEncodedImage(symbol.path);

		if (bytes == null || (symbol.alpha != null && library.__getEncodedImage(symbol.alpha) == null))
		{
			return null;
		}

		var size = readSize(bytes);
		return size != null ? new AnimateHardwareBitmapData(library, symbol, size[0], size[1]) : null;
	}

	/**
		The width and height a PNG or JPEG file gives in its header, or null.
	**/
	@:allow(swf.exporters.animate.AnimateLibrary)
	private static function readSize(bytes:Bytes):Array<Int>
	{
		var length = bytes.length;
		var width = 0;
		var height = 0;

		if (length >= 24 && bytes.get(0) == 0x89 && bytes.get(1) == 0x50 && bytes.get(2) == 0x4E && bytes.get(3) == 0x47)
		{
			// The IHDR chunk comes first
			width = (bytes.get(16) << 24) | (bytes.get(17) << 16) | (bytes.get(18) << 8) | bytes.get(19);
			height = (bytes.get(20) << 24) | (bytes.get(21) << 16) | (bytes.get(22) << 8) | bytes.get(23);
		}
		else if (length >= 4 && bytes.get(0) == 0xFF && bytes.get(1) == 0xD8)
		{
			var position = 2;

			while (position + 8 < length && bytes.get(position) == 0xFF)
			{
				var marker = bytes.get(position + 1);

				if (marker == 0xFF)
				{
					// Padding before a marker
					position++;
				}
				else if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD8))
				{
					// No segment follows these
					position += 2;
				}
				else if (marker >= 0xC0 && marker <= 0xCF && marker != 0xC4 && marker != 0xC8 && marker != 0xCC)
				{
					// A frame header
					height = (bytes.get(position + 5) << 8) | bytes.get(position + 6);
					width = (bytes.get(position + 7) << 8) | bytes.get(position + 8);
					break;
				}
				else if (marker == 0xD9 || marker == 0xDA)
				{
					break;
				}
				else
				{
					position += 2 + ((bytes.get(position + 2) << 8) | bytes.get(position + 3));
				}
			}
		}

		return width > 0 && height > 0 ? [width, height] : null;
	}

	public override function clone():BitmapData
	{
		if (__isValid && image == null && __texture == null)
		{
			// There is no texture to share yet, and a plain clone would never
			// have an image: this one decodes it for itself when it is drawn
			var bitmapData = new AnimateHardwareBitmapData(__library, __symbol, width, height);
			bitmapData.__worldTransform.copyFrom(__worldTransform);
			bitmapData.__renderTransform.copyFrom(__renderTransform);
			return bitmapData;
		}

		if (__texture != null && image == null)
		{
			__textureShared = true;
		}

		return super.clone();
	}

	public override function getTexture(context:Context3D):TextureBase
	{
		if (image == null && __isValid && (__texture == null || __textureContext != context.__context))
		{
			__decodeImage();
		}

		__lastUsed = AnimateLibrary.__hardwareBitmapClock;

		return super.getTexture(context);
	}

	/**
		Disposes of the texture if none was asked for in the last `idleTime`
		seconds. The next draw decodes the image and uploads it again.
	**/
	@:allow(swf.exporters.animate.AnimateLibrary)
	private function __releaseIdleTexture(idleTime:Float):Bool
	{
		if (__texture == null || __textureShared || AnimateLibrary.__hardwareBitmapClock - __lastUsed < idleTime)
		{
			return false;
		}

		__texture.dispose();
		__texture = null;
		return true;
	}

	private function __decodeImage():Void
	{
		var decoded = __library.__decodeHardwareImage(__symbol);

		if (decoded != null && decoded.buffer != null)
		{
			__fromImage(decoded);
			// Still hardware-only: the texture's upload releases the image again
			readable = false;
		}
	}
}
#end
