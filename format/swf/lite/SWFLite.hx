package format.swf.lite;


import flash.display.BitmapData;
import flash.display.SimpleButton;
import format.swf.lite.symbols.BitmapSymbol;
import format.swf.lite.symbols.SpriteSymbol;
import format.swf.lite.symbols.SWFSymbol;
import format.swf.lite.MovieClip;
import haxe.io.Bytes;
import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;
import openfl.Assets;
//import org.msgpack.MsgPack;


class SWFLite {
	
	
	public static var instances = new Map<String, SWFLite> ();
	
	public var frameRate:Float;
	public var root:SpriteSymbol;
	public var symbols:Map <Int, SWFSymbol>;
	
	
	public function new () {
		
		symbols = new Map <Int, SWFSymbol> ();
		
		// distinction of symbol by class name and characters by ID somewhere?
		
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
	
	
	private static function resolveClass (name:String):Class <Dynamic> {
		
		var value = Type.resolveClass (name);
		
		#if flash
		
		if (value == null) value = Type.resolveClass (StringTools.replace (name, "openfl", "flash"));
		if (value == null) value = Type.resolveClass (StringTools.replace (name, "openfl._v2", "flash"));
		
		#else
		
		if (value == null) value = Type.resolveClass (StringTools.replace (name, "openfl._v2", "openfl"));
		
		#end
		
		return value;
		
	}
	
	
	private static function resolveEnum (name:String):Enum <Dynamic> {
		
		var value = Type.resolveEnum (name);
		
		#if flash
		
		if (value == null) value = Type.resolveEnum (StringTools.replace (name, "openfl", "flash"));
		if (value == null) value = Type.resolveEnum (StringTools.replace (name, "openfl._v2", "flash"));
		if (value == null) value = cast Type.resolveClass (name);
		if (value == null) value = cast Type.resolveClass (StringTools.replace (name, "openfl", "flash"));
		if (value == null) value = cast Type.resolveClass (StringTools.replace (name, "openfl._v2", "flash"));
		
		#else
		
		if (value == null) value = Type.resolveEnum (StringTools.replace (name, "openfl._v2", "openfl"));
		
		#end
		
		return value;
		
	}
	
	
	public function serialize ():String {
		
		var serializer = new Serializer ();
		serializer.useCache = true;
		serializer.serialize (this);
		return serializer.toString ();
		
	}
	
	
	public static function unserialize (data:String):SWFLite {
		
		if (data == null) {
			
			return null;
			
		}
		
		var unserializer = new Unserializer (data);
		unserializer.setResolver ({ resolveClass: resolveClass, resolveEnum: resolveEnum });
		
		return cast unserializer.unserialize ();
		
	}
	
	
}