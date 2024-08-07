package swf;

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

class SWFLoader implements IDisplayObjectLoader
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
		var swf = new SWF(buffer);
		var content:DisplayObject = new swf.runtime.MovieClip(swf.data);
		@:privateAccess contentLoaderInfo.width = swf.width;
		@:privateAccess contentLoaderInfo.height = swf.height;
		@:privateAccess contentLoaderInfo.frameRate = swf.frameRate;
		return Future.withValue(content);
	}
}
