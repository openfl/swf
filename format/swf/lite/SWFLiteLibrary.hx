package format.swf.lite;


import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.media.Sound;
import flash.text.Font;
import flash.utils.ByteArray;
import format.swf.lite.SWFLite;
import haxe.Unserializer;
import openfl.Assets;


@:keep class SWFLiteLibrary extends AssetLibrary {
	
	
	private var swf:SWFLite;
	
	
	public function new (swf:SWFLite) {
		
		super ();
		
		this.swf = swf;
		
		// Hack to include filter classes, macro.include is not working properly
		
		var filter = flash.filters.BlurFilter;
		var filter = flash.filters.DropShadowFilter;
		var filter = flash.filters.GlowFilter;
		
	}
	
	
	public override function exists (id:String, type:AssetType):Bool {
		
		if (id == "" && type == MOVIE_CLIP) {
			
			return true;
			
		}
		
		if (type == IMAGE || type == MOVIE_CLIP) {
			
			return swf.hasSymbol (id);
			
		}
		
		return false;
		
	}
	
	
	public override function getBitmapData (id:String):BitmapData {
		
		return swf.getBitmapData (id);
		
	}
	
	
	public override function getMovieClip (id:String):MovieClip {
		
		return swf.createMovieClip (id);
		
	}
	
	
	public override function load (handler:AssetLibrary -> Void):Void {
		
		handler (this);
		
	}
	
	
}