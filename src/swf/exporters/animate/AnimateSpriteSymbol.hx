package swf.exporters.animate;

import swf.utils.SymbolUtils;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.display.Sprite)
class AnimateSpriteSymbol extends AnimateSymbol
{
	public var baseClassName:String;
	public var frames:Array<AnimateFrame>;
	public var instanceProperties:Dynamic;
	public var scale9Grid:Rectangle;

	private var library:AnimateLibrary;

	public function new()
	{
		super();

		frames = new Array();
	}

	private function __constructor(sprite:Sprite):Void
	{
		var timeline = new AnimateTimeline(library, this);
		if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (sprite, #if flash flash.display.MovieClip.MovieClip2 #else MovieClip #end))
		{
			var movieClip:MovieClip = cast sprite;
			#if flash
			@:privateAccess cast(movieClip, flash.display.MovieClip.MovieClip2).attachTimeline(timeline);
			#else
			movieClip.scale9Grid = scale9Grid;
			movieClip.attachTimeline(timeline);
			#end
		}
		else
		{
			sprite.scale9Grid = scale9Grid;
			timeline.initializeSprite(sprite);
		}
	}

	private override function __createObject(library:AnimateLibrary):Sprite
	{
		__init(library);

		#if flash
		if (className == "flash.display.MovieClip")
		{
			className = "flash.display.MovieClip2";
		}
		#end

		var symbolType = null;

		if (className != null)
		{
			symbolType = Type.resolveClass(SymbolUtils.formatClassName(className));

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

			symbolType = Type.resolveClass(SymbolUtils.formatClassName(baseClassName));

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

		__applyInstanceProperties(sprite);

		#if flash
		if (!#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (sprite, flash.display.MovieClip.MovieClip2))
		{
			MovieClip.__constructor = null;
			__constructor(sprite);
		}
		#end

		return sprite;
	}

	private override function __init(library:AnimateLibrary):Void
	{
		#if flash
		MovieClip.__constructor = __constructor;
		#elseif !macro
		Sprite.__constructor = __constructor;
		#end

		this.library = library;
	}

	private override function __initObject(library:AnimateLibrary, instance:DisplayObject):Void
	{
		this.library = library;
		__applyInstanceProperties(instance);
		__constructor(cast instance);
	}

	private function __applyInstanceProperties(instance:DisplayObject):Void
	{
		if (instance == null || instanceProperties == null)
		{
			return;
		}

		for (field in Reflect.fields(instanceProperties))
		{
			var value = __cloneInstanceProperty(Reflect.field(instanceProperties, field));
			try
			{
				Reflect.setField(instance, field, value);
			}
			catch (_:Dynamic)
			{
				try
				{
					Reflect.setProperty(instance, field, value);
				}
				catch (_:Dynamic) {}
			}
		}
	}

	private function __cloneInstanceProperty(value:Dynamic):Dynamic
	{
		if (value == null || Std.isOfType(value, Bool) || Std.isOfType(value, String) || Std.isOfType(value, Int) || Std.isOfType(value, Float))
		{
			return value;
		}

		if (Std.isOfType(value, Array))
		{
			var copy = [];
			for (item in cast(value, Array<Dynamic>))
			{
				copy.push(__cloneInstanceProperty(item));
			}
			return copy;
		}

		var clone:Dynamic = {};
		for (field in Reflect.fields(value))
		{
			Reflect.setField(clone, field, __cloneInstanceProperty(Reflect.field(value, field)));
		}
		return clone;
	}
}
