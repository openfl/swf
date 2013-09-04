package format.swf;


import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.media.Sound;
import flash.text.Font;
import flash.utils.ByteArray;
import format.swf.lite.SWFLite;
import format.SWF;
import haxe.Unserializer;
import openfl.Assets;


class SWFAssetProvider implements IAssetProvider {
	
	
	private var cachedSWFLibraries:Map <String, SWF>;
	private var cachedSWFLiteLibraries:Map <String, SWFLite>;
	
	
	public function new () {
		
		cachedSWFLibraries = new Map <String, SWF> ();
		cachedSWFLiteLibraries = new Map <String, SWFLite> ();
		
	}
	
	
	public function exists (id:String, type:AssetType):Bool {
		
		if (id.indexOf(":") > -1 && (type == MOVIE_CLIP || type == IMAGE)) {
			
			var libraryName = id.substr(0, id.indexOf(":"));
			var libraryType = Std.string (Assets.library.get (libraryName))
			;
			
			if (libraryType != null && libraryType.toLowerCase () == "swf" || libraryType.toLowerCase () == "swf_lite") {
				
				return true;
				
			}
			
		}
		
		return false;
		
	}
	
	
	public function getBitmapData (id:String, useCache:Bool
		):BitmapData {
		
		var libraryName = id.substr(0, id.indexOf(":"));
		var symbolName = id.substr(id.indexOf(":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			return library.getBitmapData (symbolName);
			
		}
		
		return null;
		
	}
	
	
	public function getBytes (id:String):ByteArray {
		
		return null;
		
	}
	
	
	public function getFont (id:String):Font {
		
		return null;
		
	}
	
	
	private function getLibrary (libraryName:String):Dynamic {
		
		var type = Std.string (Assets.library.get (libraryName));
		
		if (type != null) {
			
			if (type.toLowerCase () == "swf_lite") {
				
				if (!cachedSWFLiteLibraries.exists(libraryName)) {
					
					var unserializer = new Unserializer (Assets.getText ("libraries/" + libraryName + ".dat"));
					unserializer.setResolver (cast { resolveEnum: resolveEnum, resolveClass: resolveClass });
					cachedSWFLiteLibraries.set (libraryName, unserializer.unserialize());
					
				}
				
				return cachedSWFLiteLibraries.get (libraryName);
				
			} else {
				
				if (!cachedSWFLibraries.exists (libraryName)) {
					
					cachedSWFLibraries.set (libraryName, new SWF (Assets.getBytes("libraries/" + libraryName + ".swf")));
					
				}
				
				return cachedSWFLibraries.get (libraryName);
			
			}
			
		}
		
		return null;
		
	}
	
	
	public function getMovieClip (id:String):MovieClip {
		
		var libraryName = id.substr(0, id.indexOf(":"));
		var symbolName = id.substr(id.indexOf(":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			return library.createMovieClip (symbolName);
			
		}
		
		return null;
		
	}
	
	
	public function getSound (id:String):Sound {
		
		return null;
		
	}
	
	
	private function resolveClass (name:String):Class <Dynamic> {
		
		name = StringTools.replace(name, "native.", "flash.");
		name = StringTools.replace(name, "browser.", "flash.");
		return Type.resolveClass(name);
		
	}
	
	
	private function resolveEnum (name:String):Enum <Dynamic> {
		
		name = StringTools.replace(name, "native.", "flash.");
		name = StringTools.replace(name, "browser.", "flash.");
		#if flash
		var value = Type.resolveEnum(name);
		if (value != null) {
			return value;
		} else {
			return cast Type.resolveClass (name);
		}
		#else
		return Type.resolveEnum(name);
		#end
		
	}
	
	
}