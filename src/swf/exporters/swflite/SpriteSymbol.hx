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
	private var resolvedBaseSymbolType:Class<Dynamic>;
	private var resolvedBaseSymbolTypeReady = false;
	private var resolvedSymbolType:Class<Dynamic>;
	private var resolvedSymbolTypeReady = false;

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
		var symbolType = __resolveSymbolType();

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

	private function __resolveSymbolType():Class<Dynamic>
	{
		var symbolType = __resolveClassName(className, false);

		if (symbolType == null)
		{
			symbolType = __resolveClassName(baseClassName, true);
		}

		return symbolType;
	}

	private function __resolveClassName(name:String, useBaseClass:Bool):Class<Dynamic>
	{
		if (name == null)
		{
			return null;
		}

		if (useBaseClass)
		{
			if (resolvedBaseSymbolTypeReady)
			{
				return resolvedBaseSymbolType;
			}
		}
		else if (resolvedSymbolTypeReady)
		{
			return resolvedSymbolType;
		}

		#if flash
		if (name == "flash.display.MovieClip")
		{
			name = "flash.display.MovieClip2";
		}
		#end

		var symbolType = Type.resolveClass(name);

		if (useBaseClass)
		{
			resolvedBaseSymbolType = symbolType;
			resolvedBaseSymbolTypeReady = true;
		}
		else
		{
			resolvedSymbolType = symbolType;
			resolvedSymbolTypeReady = true;
		}

		return symbolType;
	}
}
