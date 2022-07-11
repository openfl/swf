package swf.exporters.swflite;

import swf.exporters.swflite.SWFLite;
import swf.exporters.swflite.timeline.Frame;
import swf.exporters.swflite.timeline.SymbolTimeline;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

import #if (haxe_ver >= 4.2) Std.isOfType #else Std.is as isOfType #end;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
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

	private function __spriteConstructor(sprite:Sprite):Void
	{
		if (!isOfType(sprite, MovieClip))
			throw "expected movieclip";
		
		__movieClipConstructor(cast sprite);
	}

	private function __movieClipConstructor(movieClip:MovieClip):Void
	{
		var timeline = new SymbolTimeline(swf, this);
		#if flash
		@:privateAccess cast(movieClip, flash.display.MovieClip.MovieClip2).attachTimeline(timeline);
		#else
		movieClip.attachTimeline(timeline);
		#end
		movieClip.scale9Grid = scale9Grid;
	}

	private inline function __setConstructor()
	{
		#if (!macro && !flash)
			@:privateAccess
			#if (openfl <= "9.1.0")
			MovieClip.__constructor = __movieClipConstructor;
			#else
			Sprite.__constructor = __spriteConstructor;
			#end
		#end
	}

	private override function __createObject(swf:SWFLite):MovieClip
	{
		__setConstructor();
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
		if (!isOfType(movieClip, flash.display.MovieClip.MovieClip2))
		{
			movieClip.scale9Grid = scale9Grid;
		}
		#end

		return movieClip;
	}

	private override function __init(swf:SWFLite):Void
	{
		__setConstructor();
		this.swf = swf;
	}

	private override function __initObject(swf:SWFLite, instance:DisplayObject):Void
	{
		this.swf = swf;
		__movieClipConstructor(cast instance);
	}
}
