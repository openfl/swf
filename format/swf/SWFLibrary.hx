package format.swf;


import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.text.Font;
import flash.utils.ByteArray;
import format.SWF;
import haxe.Unserializer;
import openfl.Assets;


@:keep class SWFLibrary extends AssetLibrary {
	
	
	private var context:LoaderContext;
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
		
		//var ret/*:Class*/ = loader.contentLoaderInfo.applicationDomain.getDefinition (id);
		//trace(ret);
		
		var bmd = Type.createEmptyInstance(cast loader.contentLoaderInfo.applicationDomain.getDefinition(id));
		
		trace (bmd);
		return bmd;
		
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
		
		context = new LoaderContext (false, ApplicationDomain.currentDomain, null);
		context.allowCodeImport = true;
		
		if (Assets.isLocal (id, AssetType.BINARY)) {
			
			loader = new Loader ();
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, function (_) {
				
				handler (this);
				
			});
			loader.loadBytes (Assets.getBytes (id), context);
			
		} else {
			
			loader = new Loader ();
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, function (_) {
				
				handler (this);
				
			});
			loader.load (new URLRequest (Assets.getPath (id)), context);
			
		}
		
		#else
		
		if (swf == null) {
			
			swf = new SWF (Assets.getBytes (id));
			handler (this);
			
		}
		
		#end
		
	}
	
	
}