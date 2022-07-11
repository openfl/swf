package swf.exporters.swflite;

import swf.exporters.swflite.SWFLite;
import swf.exporters.swflite.timeline.Frame;
import swf.exporters.swflite.timeline.SymbolTimeline;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.Sprite)
class SpriteSymbol extends SWFSymbol
{
	public var baseClassName:String;
	public var frames:Array<Frame>;
	public var scale9Grid:Rectangle;

	private var swf:SWFLite;

	public function new()
	{
		super();

		frames = new Array<Frame>();
	}

	private function __constructor(sprite:Sprite):Void
	{
		var timeline = new SymbolTimeline(swf, this);
		if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (sprite, MovieClip))
		{
			var movieClip:MovieClip = cast sprite;
			#if flash
			@:privateAccess cast(movieClip, flash.display.MovieClip.MovieClip2).attachTimeline(timeline);
			#else
			movieClip.attachTimeline(timeline);
			#end
			movieClip.scale9Grid = scale9Grid;
		}
		else
		{
			sprite.scale9Grid = scale9Grid;
			timeline.initializeSprite(sprite);
		}
	}

	private override function __createObject(swf:SWFLite):Sprite
	{
		#if (!macro && !flash)
		Sprite.__constructor = __constructor;
		#end
		this.swf = swf;

		#if flash
		if (className == "flash.display.MovieClip")
		{
			className = "flash.display.MovieClip2";
		}
		#end

		var symbolType = null;

		if (className != null)
		{
			symbolType = Type.resolveClass(className);

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

			symbolType = Type.resolveClass(baseClassName);

			if (symbolType == null)
			{
				// Log.warn ("Could not resolve class \"" + className + "\"");
			}
		}

		var sprite:Sprite = null;

		if (symbolType != null)
		{
			sprite = Type.createInstance(symbolType, []);
		}
		else
		{
			#if flash
			sprite = new flash.display.MovieClip.MovieClip2();
			#else
			sprite = new MovieClip();
			#end
		}

		#if flash
		if (!#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (sprite, flash.display.MovieClip.MovieClip2))
		{
			sprite.scale9Grid = scale9Grid;
		}
		#end

		return sprite;
	}

	private override function __init(swf:SWFLite):Void
	{
		#if (!macro && !flash)
		Sprite.__constructor = __constructor;
		#end
		this.swf = swf;
	}

	private override function __initObject(swf:SWFLite, instance:DisplayObject):Void
	{
		this.swf = swf;
		__constructor(cast instance);
	}
}
