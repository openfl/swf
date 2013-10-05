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


@:keep class SWFLibrary extends AssetLibrary {
	
	
	private var id:String;
	private var loader:Loader;
	private var swf:SWF;
	
	
	public function new (id:String) {
		
		super ();
		
		this.id = id;
		
	}
	
	
	public override function exists (id:String, type:AssetType):Bool {
		
		if (id == "" && type == MOVIE_CLIP) {
			
			return true;
			
		}
		
		if (type == IMAGE || type == MOVIE_CLIP) {
			
			#if flash
			
			return loader.contentLoaderInfo.applicationDomain.hasDefinition (id);
			
			#else
			
			return swf.hasSymbol (id);
			
			#end
			
		}
		
		return false;
		
	}
	
	
	public override function getBitmapData (id:String):BitmapData {
		
		#if flash
		
		return loader.contentLoaderInfo.applicationDomain.getDefinition (id);
		
		#else
		
		return swf.getBitmapData (id);
		
		#end
		
	}
	
	
	public override function getMovieClip (id:String):MovieClip {
		
		#if flash
		
		if (id == "") {
			
			return cast loader.content;
			
		} else {
			
			return cast Type.createInstance (loader.contentLoaderInfo.applicationDomain.getDefinition (id), []);
			
		}
		
		#else
		
		return swf.createMovieClip (id);
		
		#end
		
	}
	
	
	public override function load (handler:AssetLibrary -> Void):Void {
		
		#if flash
		
		loader = new Loader ();
		loader.contentLoaderInfo.addEventListener (Event.COMPLETE, function (_) {
			
			handler (this);
				
		});
		loader.loadBytes (Assets.getBytes (id));
		
		#else
		
		if (swf == null) {
			
			swf = new SWF (Assets.getBytes (id));
			handler (this);
			
		}
		
		#end
		
	}
	
	
}