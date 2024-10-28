package swf.exporters.animate;
#if (openfl >= "9.5.0")
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
#end
class AnimateLoader implements IDisplayObjectLoader
{
	public function new() {
		#if (openfl < "9.5.0")
		openfl.Lib.notImplemented();
		#end
	}

	public function load(request:URLRequest, context:LoaderContext, contentLoaderInfo:LoaderInfo):Future<DisplayObject>
	{
		#if (openfl < "9.5.0")
		openfl.Lib.notImplemented();
		#else
		// TODO
		return null;
		#end
	}

	public function loadBytes(buffer:ByteArray, context:LoaderContext, contentLoaderInfo:LoaderInfo):Future<DisplayObject>
	{
		#if (openfl < "9.5.0")
		openfl.Lib.notImplemented();
		#else
		return null;
		#end
	}
}
