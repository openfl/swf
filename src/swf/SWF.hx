package swf;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.display.SimpleButton;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.TimerEvent;
import openfl.utils.ByteArray;
import openfl.utils.Timer;
import swf.SWFRoot;
import swf.SWFTimelineContainer;
import swf.tags.TagDefineBits;
import swf.tags.TagDefineBitsJPEG2;
import swf.tags.TagDefineBitsLossless;
import swf.tags.TagDefineButton2;
import swf.tags.TagDefineSprite;
import swf.tags.TagSymbolClass;

class SWF extends EventDispatcher
{
	public var data:SWFRoot;

	public static var instances = new Map<String, SWF>();

	public var backgroundColor(default, null):Int;
	public var frameRate(default, null):Float;
	public var height(default, null):Int;
	public var symbols:Map<String, Int>;
	public var width(default, null):Int;

	private var complete:Bool;

	public function new(bytes:ByteArray)
	{
		super();

		// SWFTimelineContainer.AUTOBUILD_LAYERS = true;
		data = new SWFRoot(bytes);

		backgroundColor = data.backgroundColor;
		frameRate = data.frameRate;
		width = Std.int(data.frameSize.rect.width);
		height = Std.int(data.frameSize.rect.height);

		symbols = data.symbols;

		#if flash
		var allTags = 0;
		var loadedTags = 0;

		var handler = function(_)
		{
			loadedTags++;

			if (loadedTags >= allTags)
			{
				dispatchCompleteTimer();
			}
		}

		for (tag in data.tags)
		{
			if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (tag, TagDefineBits))
			{
				allTags++;

				var bits:TagDefineBits = cast tag;
				bits.exportBitmapData(handler);
			}
			/*else if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (tag, TagDefineBitsLossless)) {

				allTags++;

				var bits:TagDefineBitsLossless = cast tag;
				bits.exportBitmapData (handler);

			}*/
		}

		if (allTags == 0)
		{
			dispatchCompleteTimer();
		}
		#else
		dispatchCompleteTimer();
		#end
	}

	public override function addEventListener(type:String, listener:Dynamic, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void
	{
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);

		if (complete)
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}

	public function createButton(className:String):SimpleButton
	{
		var symbol:Dynamic = null;
		var charId:Int;

		if (symbols.exists(className))
		{
			charId = symbols.get(className);
			symbol = data.getCharacter(charId);
		}

		// if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (symbol, TagDefineButton2)) {

		// 	return new SimpleButton (data, cast symbol);

		// }

		return null;
	}

	public function createMovieClip(className:String = ""):MovieClip
	{
		var symbol:Dynamic = null;
		var charId:Int;
		if (className == "")
		{
			symbol = data;
		}
		else
		{
			if (symbols.exists(className))
			{
				charId = symbols.get(className);

				if (charId > 0)
				{
					symbol = data.getCharacter(charId);
				}
				else
				{
					symbol = data;
				}
			}
		}

		// if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (symbol, SWFTimelineContainer)) {

		// 	return new MovieClip (cast symbol);

		// }

		return null;
	}

	private inline function dispatchCompleteTimer():Void
	{
		var timer = new Timer(1, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, dispatchComplete);
		timer.start();
	}

	private function dispatchComplete(e:TimerEvent):Void
	{
		complete = true;
		dispatchEvent(new Event(Event.COMPLETE));
	}

	public function getBitmapData(className:String):BitmapData
	{
		var symbol:Dynamic = null;

		if (className == "")
		{
			symbol = data;
		}
		else
		{
			if (symbols.exists(className))
			{
				symbol = data.getCharacter(symbols.get(className));
			}
		}

		if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (symbol, TagDefineBits)
			|| #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end (symbol, TagDefineBitsLossless))
		{
			return new Bitmap(cast symbol).bitmapData;
		}

		return null;
	}

	public function getTextData(className:String):String{
		var symbol:TagDefineBinaryData = null;
		
			
		if (symbols.exists(className))
		{			
			symbol = cast data.getCharacter(symbols.get(className));
			return symbol.binaryData.readUTFBytes(symbol.binaryData.length);			
		}
		
		return "";
	}

	public function hasSymbol(className:String):Bool
	{
		return symbols.exists(className);
		// return streamPositions.exists (id);
	}
}
