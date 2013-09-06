package format;


import flash.display.BitmapData;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import format.swf.instance.Bitmap;
import format.swf.instance.MovieClip;
import format.swf.SWFRoot;
import format.swf.SWFTimelineContainer;
import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsJPEG2;
import format.swf.tags.TagDefineBitsLossless;
import format.swf.tags.TagDefineSprite;
import format.swf.tags.TagSymbolClass;

#if !haxe3
typedef Map<String, T> = Hash<T>;
#end


class SWF extends EventDispatcher {
	
	
	public var data:SWFRoot;
	public static var instances = new Map<String, SWF> ();
	
	public var backgroundColor (default, null):Int;
	public var frameRate (default, null):Float;
	public var height (default, null):Int;
	public var symbols:Map <String, Int>;
	public var width (default, null):Int;
	
	private var complete:Bool;
	
	
	public function new (bytes:ByteArray) {
		
		super ();
		
		//SWFTimelineContainer.AUTOBUILD_LAYERS = true;
		data = new SWFRoot (bytes);
		
		backgroundColor = data.backgroundColor;
		frameRate = data.frameRate;
		width = Std.int (data.frameSize.rect.width);
		height = Std.int (data.frameSize.rect.height);
		
		symbols = new Map <String, Int> ();
		
		for (tag in data.tags) {
			
			if (Std.is (tag, TagSymbolClass)) {
				
				for (symbol in cast (tag, TagSymbolClass).symbols) {
					
					symbols.set (symbol.name, symbol.tagId);
					
				}
				
			}
			
		}
		
		#if flash
		
		var allTags = 0;
		var loadedTags = 0;
		
		var handler = function (_) {
			
			loadedTags++;
			
			if (loadedTags >= allTags) {
				
				complete = true;
				dispatchEvent (new Event (Event.COMPLETE));
				
			}
			
		}
		
		for (tag in data.tags) {
			
			if (Std.is (tag, TagDefineBits)) {
				
				allTags++;
				
				var bits:TagDefineBits = cast tag;
				bits.exportBitmapData (handler);
				
			} /*else if (Std.is (tag, TagDefineBitsLossless)) {
				
				allTags++;
				
				var bits:TagDefineBitsLossless = cast tag;
				bits.exportBitmapData (handler);
				
			}*/
			
		}
		
		#else
		
		complete = true;
		dispatchEvent (new Event (Event.COMPLETE));
		
		#end
		
	}
	
	
	public override function addEventListener (type:String, listener:Dynamic, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		
		super.addEventListener (type, listener, useCapture, priority, useWeakReference);
		
		if (complete) {
			
			dispatchEvent (new Event (Event.COMPLETE));
			
		}
		
	}
	
	
	public function createButton (className:String):SimpleButton {
		
		var id = symbols.get (className);
		/*
		switch (getSymbol (id)) {
			
			case buttonSymbol (data):
				
				var b = new SimpleButton ();
				data.apply (b);
				return b;
			
			default:
				
				return null;
			
		}
		*/
		return null;
		
	}
	
	
	public function createMovieClip (className:String = ""):MovieClip {
		
		var symbol:Dynamic = null;
		
		if (className == "") {
			
			symbol = data;
			
		} else {
			
			if (symbols.exists (className)) {
				
				symbol = data.getCharacter (symbols.get (className));
				
			}
			
		}
		
		if (Std.is (symbol, SWFTimelineContainer)) {
			
			return new MovieClip (cast symbol);
			
		}
		
		return null;
		
	}
	
	
	public function getBitmapData (className:String):BitmapData {
		
		var symbol:Dynamic = null;
		
		if (className == "") {
			
			symbol = data;
			
		} else {
			
			if (symbols.exists (className)) {
				
				symbol = data.getCharacter (symbols.get (className));
				
			}
			
		}
		
		if (Std.is (symbol, TagDefineBits) || Std.is (symbol, TagDefineBitsLossless)) {
			
			return new Bitmap (cast symbol).bitmapData;
			
		}
		
		return null;
		
	}
	
	
	public function hasSymbol (className:String):Bool {
		
		return symbols.exists (className);
		//return streamPositions.exists (id);
		
	}	
	
	
}