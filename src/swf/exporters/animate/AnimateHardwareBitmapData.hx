package swf.exporters.animate;

#if (lime && !flash && swf_hardware_bitmap_cache)
import lime.graphics.cairo.CairoImageSurface;
import lime.utils.Bytes;
import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.display3D.textures.TextureBase;
import openfl.events.Event;
import openfl.geom.Rectangle;

/**
	A hardware-only bitmap of an Animate library that decodes its image when a
	texture is first asked for, and again if the texture is lost, instead of
	when a symbol that uses it is created. It decodes it for the software
	renderer too, as `BitmapData.draw()` into a readable bitmap uses, into a
	copy that is let go once it is no longer drawn.
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
	// A clone draws with this bitmap's texture, which neither lets go of
	private var __textureShared:Bool = false;
	// The decoded copy the software renderer draws from, and when it was last asked for
	private var __softwareCopy:BitmapData;
	private var __softwareCopyUsed:Float = 0;

	// The seconds a copy for the software renderer is kept after it was last drawn
	private static inline var SOFTWARE_COPY_IDLE_TIME:Float = 2;

	private static var __softwareCopies:Array<AnimateHardwareBitmapData> = [];
	private static var __softwareCopiesListening:Bool = false;

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
		if (__isValid && image == null)
		{
			// A plain clone would never have an image: this one decodes it
			// for itself when it is drawn
			var bitmapData = new AnimateHardwareBitmapData(__library, __symbol, width, height);

			if (__texture != null)
			{
				bitmapData.__texture = __texture;
				bitmapData.__textureContext = __textureContext;
				__textureShared = bitmapData.__textureShared = true;
			}

			bitmapData.__worldTransform.copyFrom(__worldTransform);
			bitmapData.__renderTransform.copyFrom(__renderTransform);
			return bitmapData;
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
		What the software renderer draws this bitmap from: a decoded copy,
		kept while it is drawn. OpenFL asks for it for a `Bitmap`, and for a
		fill or a `BitmapData` drawn as it is where it asks a bitmap that is
		not readable.
	**/
	public override function getSurface():CairoImageSurface
	{
		#if lime_cairo
		if (!readable && __isValid)
		{
			if (__softwareCopy == null)
			{
				__softwareCopy = BitmapData.fromImage(__library.__decodeHardwareImage(__symbol), transparent);

				if (__softwareCopy == null)
				{
					return null;
				}

				__softwareCopies.push(this);

				if (!__softwareCopiesListening)
				{
					__softwareCopiesListening = true;
					openfl.Lib.current.addEventListener(Event.ENTER_FRAME, __onSoftwareCopiesFrame);
				}
			}

			__softwareCopyUsed = haxe.Timer.stamp();
			return __softwareCopy.getSurface();
		}
		#end

		return super.getSurface();
	}

	private static function __onSoftwareCopiesFrame(_:Event):Void
	{
		__releaseIdleSoftwareCopies(haxe.Timer.stamp() - SOFTWARE_COPY_IDLE_TIME);

		if (__softwareCopies.length == 0)
		{
			__softwareCopiesListening = false;
			openfl.Lib.current.removeEventListener(Event.ENTER_FRAME, __onSoftwareCopiesFrame);
		}
	}

	/**
		Lets go of the copies for the software renderer that were last drawn
		at `time` or before, and returns how many are left.
	**/
	private static function __releaseIdleSoftwareCopies(time:Float):Int
	{
		var index = __softwareCopies.length;

		while (--index >= 0)
		{
			var bitmapData = __softwareCopies[index];

			if (bitmapData.__softwareCopy == null || bitmapData.__softwareCopyUsed <= time)
			{
				bitmapData.__releaseSoftwareCopy();
				__softwareCopies.splice(index, 1);
			}
		}

		return __softwareCopies.length;
	}

	private function __releaseSoftwareCopy():Void
	{
		if (__softwareCopy != null)
		{
			__softwareCopy.dispose();
			__softwareCopy = null;
		}
	}

	public override function dispose():Void
	{
		__releaseSoftwareCopy();
		super.dispose();
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
