package swf.exporters.animate;

import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.geom.Rectangle;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.MovieClip)
class AnimateSpriteSymbol extends AnimateSymbol
{
	public var baseClassName:String;
	public var frames:Array<AnimateFrame>;
	public var scale9Grid:Rectangle;

	private var library:AnimateLibrary;

	public function new()
	{
		super();

		frames = new Array();
	}

	private function __constructor(movieClip:MovieClip):Void
	{
		var timeline = new AnimateTimeline(library, this);
		#if flash
		@:privateAccess cast(movieClip, flash.display.MovieClip.MovieClip2).attachTimeline(timeline);
		#else
		movieClip.scale9Grid = scale9Grid;
		movieClip.attachTimeline(timeline);
		#end
	}

	private override function __createObject(library:AnimateLibrary):MovieClip
	{
		#if !macro
		MovieClip.__constructor = __constructor;
		#end
		this.library = library;

		#if flash
		if (className == "flash.display.MovieClip")
		{
			className = "flash.display.MovieClip2";
		}
		#end

		var symbolType = null;

		if (className != null)
		{
			symbolType = Type.resolveClass(formatClassName(className));

			if (symbolType == null)
			{
				// Log.warn ("Could not resolve class \"" + className + "\"");
			}
		}

		if (symbolType == null && baseClassName != null)
		{
			#if flash
			if (baseClassName == "flash.display.MovieClip")
			{
				baseClassName = "flash.display.MovieClip2";
			}
			#end

			symbolType = Type.resolveClass(formatClassName(baseClassName));

			if (symbolType == null)
			{
				// Log.warn ("Could not resolve class \"" + className + "\"");
			}
		}

		var movieClip:MovieClip = null;

		if (symbolType != null)
		{
			movieClip = Type.createInstance(symbolType, []);
		}
		else
		{
			#if flash
			movieClip = new flash.display.MovieClip.MovieClip2();
			#else
			movieClip = new MovieClip();
			#end
		}

		#if flash
		if (!Std.is(movieClip, flash.display.MovieClip.MovieClip2))
		{
			movieClip.scale9Grid = scale9Grid;
		}
		#end

		return movieClip;
	}

	private function formatClassName(className:String, prefix:String = null):String
	{
		if (className == null) return null;
		if (prefix == null) prefix = "";

		var lastIndexOfPeriod = className.lastIndexOf(".");

		var packageName = "";
		var name = "";

		if (lastIndexOfPeriod == -1)
		{
			name = prefix + className;
		}
		else
		{
			packageName = className.substr(0, lastIndexOfPeriod);
			name = prefix + className.substr(lastIndexOfPeriod + 1);
		}

		packageName = packageName.charAt(0).toLowerCase() + packageName.substr(1);
		name = name.substr(0, 1).toUpperCase() + name.substr(1);

		if (packageName != "")
		{
			return StringTools.trim(packageName + "." + name);
		}
		else
		{
			return StringTools.trim(name);
		}
	}

	private override function __init(library:AnimateLibrary):Void
	{
		#if !macro
		MovieClip.__constructor = __constructor;
		#end
		this.library = library;
	}

	private override function __initObject(library:AnimateLibrary, instance:DisplayObject):Void
	{
		this.library = library;
		__constructor(cast instance);
	}
}
