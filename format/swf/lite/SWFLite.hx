package format.swf.lite;


import flash.display.BitmapData;
import flash.display.SimpleButton;
import format.swf.lite.symbols.BitmapSymbol;
import format.swf.lite.symbols.SpriteSymbol;
import format.swf.lite.symbols.SWFSymbol;
import format.swf.lite.MovieClip;
import haxe.Json;
import openfl.Assets;


class SWFLite {
	
	
	public static var instances = new Map<String, SWFLite> ();
	
	public var frameRate:Float;
	public var root:SpriteSymbol;
	public var symbols:Map <Int, SWFSymbol>;
	
	
	public function new () {
		
		symbols = new Map <Int, SWFSymbol> ();
		
		// distinction of symbol by class name ad characters by ID somewhere?
		
		
	}
	
	
	public function createButton (className:String):SimpleButton {
		
		return null;
		
	}
	
	
	public function createMovieClip (className:String = ""):MovieClip {
		
		if (className == "") {
			
			return new MovieClip (this, root);
			
		} else {
			
			for (symbol in symbols) {
				
				if (symbol.className == className) {
					
					if (Std.is (symbol, SpriteSymbol)) {
						
						return new MovieClip (this, cast symbol);
						
					}
					
				}
				
			}
			
		}
		
		return null;
		
	}
	
	
	public function getBitmapData (className:String):BitmapData {
		
		for (symbol in symbols) {
			
			if (symbol.className == className) {
				
				if (Std.is (symbol, BitmapSymbol)) {
					
					var bitmap:BitmapSymbol = cast symbol;
					return Assets.getBitmapData (bitmap.path);
					
				}
				
			}
			
		}
		
		return null;
		
	}
	
	
	public function hasSymbol (className:String):Bool {
		
		for (symbol in symbols) {
			
			if (symbol.className == className) {
				
				return true;
				
			}
			
		}
		
		return false;
		
	}
	
	
	public function serialize ():String {
		
		var object:Dynamic = {};
		object.frameRate = frameRate;
		object.root = root.prepare ();
		
		var symbolData = [];
		
		for (id in symbols.keys ()) {
			
			var character:Dynamic = {};
			character.id = id;
			character.symbol = symbols.get (id).prepare ();
			
			symbolData.push (character);
			
		}
		
		object.symbols = symbolData;
		
		return Json.stringify (object);
		
	}
	
	
	public static function unserialize (data:String):SWFLite {
		
		var object:Dynamic = Json.parse (data);
		var swfLite = new SWFLite ();
		swfLite.frameRate = object.frameRate;
		swfLite.root = cast SWFSymbol.unserialize (object.root);
		
		for (character in cast (object.symbols, Array<Dynamic>)) {
			
			swfLite.symbols.set (character.id, SWFSymbol.unserialize (character.symbol));
			
		}
		
		return swfLite;
		
	}
	
	
}