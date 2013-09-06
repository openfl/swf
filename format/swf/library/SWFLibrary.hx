package format.swf.library;


import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.media.Sound;
import flash.text.Font;
import flash.utils.ByteArray;
import format.SWF;
import haxe.Unserializer;
import openfl.Assets;


class SWFLibrary extends AssetLibrary {
	
	
	private var id:String;
	private var swf:SWF;
	
	
	public function new (id:String) {
		
		super ();
		
		this.id = id;
		
	}
	
	
	public override function exists (id:String, type:AssetType):Bool {
		
		initialize ();
		
		if (id == "" && type == MOVIE_CLIP) {
			
			return true;
			
		}
		
		if (type == IMAGE || type == MOVIE_CLIP) {
			
			return swf.hasSymbol (id);
			
		}
		
		return false;
		
	}
	
	
	public override function getBitmapData (id:String):BitmapData {
		
		initialize ();
		
		return swf.getBitmapData (id);
		
	}
	
	
	public override function getMovieClip (id:String):MovieClip {
		
		initialize ();
		
		return swf.createMovieClip (id);
		
	}
	
	
	private function initialize ():Void {
		
		if (swf == null) {
			
			swf = new SWF (Assets.getBytes (id));
			
		}
		
	}
	
	
}