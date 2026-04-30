package swf.exporters.animate;

import swf.utils.SymbolUtils;
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

	private var resolvedSymbolType:Class<Dynamic>;
	private var resolvedSymbolTypeReady = false;

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
		var symbolType = __resolveSymbolType();

		if (symbolType != null)
		{
			AnimateGeneratedTypeContext.setBitmap(library, this);

			try
			{
				var bitmapData:BitmapData = cast Type.createInstance(symbolType, []);
				AnimateGeneratedTypeContext.clearBitmapIfMatches(library, this);
				if (bitmapData != null)
				{
					return bitmapData;
				}
			}
			catch (e:Dynamic)
			{
				AnimateGeneratedTypeContext.clearBitmap();
				throw e;
			}
		}

		return BitmapData.fromImage(library.getImage(path));
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

		resolvedSymbolType = Type.resolveClass(SymbolUtils.formatClassName(className));
		resolvedSymbolTypeReady = true;
		return resolvedSymbolType;
	}
}
