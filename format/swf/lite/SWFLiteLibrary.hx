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

#if (lime && !lime_legacy)
import lime.graphics.Image;
#end


@:keep class SWFLiteLibrary extends AssetLibrary {
	
	
	private var swf:SWFLite;
	
	
	public function new (id:String) {
		
		super ();
		
		if (id != null) {
			
			swf = SWFLite.unserialize (Assets.getText (id));
			
		}
		
		// Hack to include filter classes, macro.include is not working properly
		
		//var filter = flash.filters.BlurFilter;
		//var filter = flash.filters.DropShadowFilter;
		//var filter = flash.filters.GlowFilter;
		
	}
	
	
	#if (!lime || lime_legacy)
	public override function exists (id:String, type:AssetType):Bool {
	#else
	public override function exists (id:String, type:String):Bool {
	#end
		
		if (id == "" && type == (cast AssetType.MOVIE_CLIP)) {
			
			return true;
			
		}
		
		if (type == (cast AssetType.IMAGE) || type == (cast AssetType.MOVIE_CLIP)) {
			
			return swf.hasSymbol (id);
			
		}
		
		return false;
		
	}
	
	
	#if (!lime || lime_legacy)
	public override function getBitmapData (id:String):BitmapData {
		
		return swf.getBitmapData (id);
		
	}
	#else
	public override function getImage (id:String):Image {
		
		return Image.fromBitmapData (swf.getBitmapData (id));
		
	}
	#end
	
	
	public override function getMovieClip (id:String):MovieClip {
		
		return swf.createMovieClip (id);
		
	}
	
	
	public override function load (handler:AssetLibrary -> Void):Void {
		
		handler (this);
		
	}
	
	
	private static function resolveClass (name:String):Class <Dynamic> {
		
		var value = Type.resolveClass (name);
		
		if (value == null) {
			
			#if flash
			value = Type.resolveClass (StringTools.replace (name, "openfl._v2", "flash"));
			#else
			value = Type.resolveClass (StringTools.replace (name, "openfl._v2", "openfl"));
			#end
			
		}
		
		return value;
		
	}
	
	
	private static function resolveEnum (name:String):Enum <Dynamic> {
		
		var value = Type.resolveEnum (name);
		
		if (value == null) {
			
			#if flash
			value = Type.resolveEnum (StringTools.replace (name, "openfl._v2", "flash"));
			#else
			value = Type.resolveEnum (StringTools.replace (name, "openfl._v2", "openfl"));
			#end
			
		}
		
		#if flash
		
		if (value == null) {
			
			return cast Type.resolveClass (name);
			
		}
		
		#end
		
		return value;
		
	}
	
	
}