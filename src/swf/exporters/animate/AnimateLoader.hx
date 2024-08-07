package swf.exporters.animate;

import openfl.utils.Promise;
import openfl.display.DisplayObject;
import openfl.display.IDisplayObjectLoader;
import openfl.display.LoaderInfo;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.system.LoaderContext;
import openfl.utils.ByteArray;
import openfl.utils.Future;

class AnimateLoader implements IDisplayObjectLoader
{
	public function new() {}

	public function load(request:URLRequest, context:LoaderContext, contentLoaderInfo:LoaderInfo):Future<DisplayObject>
	{
		// TODO
		return null;
	}

	public function loadBytes(buffer:ByteArray, context:LoaderContext, contentLoaderInfo:LoaderInfo):Future<DisplayObject>
	{
		return null;
	}
}
