package swf.exporters.animate;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class AnimateBitmapSymbol extends AnimateSymbol
{
	public var alpha:String;
	public var path:String;
	public var smooth:Null<Bool>;

	public function new()
	{
		super();
	}

	private override function __createObject(library:AnimateLibrary):Bitmap
	{
		#if lime
		return new Bitmap(__createBitmapData(library), PixelSnapping.AUTO, smooth != false);
		#else
		return null;
		#end
	}

	private function __createBitmapData(library:AnimateLibrary):BitmapData
	{
		#if (lime && !flash && swf_hardware_bitmap_cache)
		return library.__getHardwareBitmapData(this);
		#else
		return __createBitmapDataUncached(library);
		#end
	}

	@:allow(swf.exporters.animate.AnimateLibrary)
	private function __createBitmapDataUncached(library:AnimateLibrary):BitmapData
	{
		var image = library.getImage(path);
		return image != null ? BitmapData.fromImage(image) : null;
	}
}
