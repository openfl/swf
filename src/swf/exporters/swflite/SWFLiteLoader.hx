package swf.exporters.swflite;

import lime.graphics.Image;
import openfl.display.DisplayObject;
import openfl.display.IDisplayObjectLoader;
import openfl.display.LoaderInfo;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
import openfl.utils.ByteArray;
import openfl.utils.Future;
import openfl.utils.Promise;
import swf.exporters.SWFLiteExporter;

@:access(swf.exporters.swflite.SWFLiteLibrary)
class SWFLiteLoader implements IDisplayObjectLoader
{
	public function new() {}

	public function load(request:URLRequest, context:LoaderContext, contentLoaderInfo:LoaderInfo):Future<DisplayObject>
	{
		if (contentLoaderInfo.contentType != null && contentLoaderInfo.contentType == "application/x-shockwave-flash")
		{
			var promise = new Promise<DisplayObject>();

			var loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, function(event)
			{
				promise.completeWith(loadBytes(loader.data, context, contentLoaderInfo));
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event)
			{
				promise.error(event);
			});
			loader.addEventListener(ProgressEvent.PROGRESS, function(event)
			{
				promise.progress(Std.int(event.bytesLoaded), Std.int(event.bytesTotal));
			});
			loader.load(request);

			return promise.future;
		}
		else
		{
			return null;
		}
	}

	public function loadBytes(buffer:ByteArray, context:LoaderContext, contentLoaderInfo:LoaderInfo):Future<DisplayObject>
	{
		// TODO: No intermediate format
		var swf = new SWF(buffer);
		var exporter = new SWFLiteExporter(swf.data);
		var swfLite = exporter.swfLite;
		var library = new SWFLiteLibrary("test");
		swfLite.library = library;
		library.swf = swfLite;

		for (id in exporter.bitmaps.keys())
		{
			var type = exporter.bitmapTypes.get(id) == BitmapType.PNG ? "png" : "jpg";
			var symbol:BitmapSymbol = cast swfLite.symbols.get(id);
			symbol.path = id + "." + type;
			swfLite.symbols.set(id, symbol);
			library.cachedImages.set(symbol.path, Image.fromBytes(exporter.bitmaps.get(id)));

			if (exporter.bitmapTypes.get(id) == BitmapType.JPEG_ALPHA)
			{
				symbol.alpha = id + "a.png";
				library.cachedImages.set(symbol.alpha, Image.fromBytes(exporter.bitmapAlpha.get(id)));
			}
		}

		var content:DisplayObject = exporter.swfLite.createMovieClip("");
		@:privateAccess contentLoaderInfo.width = swf.width;
		@:privateAccess contentLoaderInfo.height = swf.height;
		@:privateAccess contentLoaderInfo.frameRate = swf.frameRate;
		@:privateAccess contentLoaderInfo.assetLibrary = library;
		return Future.withValue(content);
	}
}
