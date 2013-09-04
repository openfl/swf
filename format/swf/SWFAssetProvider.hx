package format.swf;


import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.media.Sound;
import flash.text.Font;
import flash.utils.ByteArray;
import format.swf.lite.SWFLite;
import format.SWF;
import haxe.Unserializer;
import openfl.Assets;


class SWFAssetProvider implements IAssetProvider {
	
	
	private var cachedLoaders:Map <String, Loader>;
	private var cachedSWFLibraries:Map <String, SWF>;
	private var cachedSWFLiteLibraries:Map <String, SWFLite>;
	
	
	public function new () {
		
		cachedLoaders = new Map <String, Loader> ();
		cachedSWFLibraries = new Map <String, SWF> ();
		cachedSWFLiteLibraries = new Map <String, SWFLite> ();
		
	}
	
	
	public function getBitmapData (id:String, useCache:Bool):BitmapData {
		
		var libraryName = id.substr(0, id.indexOf(":"));
		var symbolName = id.substr(id.indexOf(":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			#if flash
			
			if (Std.is (library, Loader)) {
				
				return cast (library, Loader).contentLoaderInfo.applicationDomain.getDefinition (symbolName);
				
			}
			
			#end
			
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
				
				#if flash
				
				return cachedLoaders.get (libraryName);
				
				#else
				
				if (!cachedSWFLibraries.exists (libraryName)) {
					
					cachedSWFLibraries.set (libraryName, new SWF (Assets.getBytes("libraries/" + libraryName + ".swf")));
					
				}
				
				return cachedSWFLibraries.get (libraryName);
				
				#end
			
			}
			
		}
		
		return null;
		
	}
	
	
	public function getMovieClip (id:String):MovieClip {
		
		var libraryName = id.substr(0, id.indexOf(":"));
		var symbolName = id.substr(id.indexOf(":") + 1);
		var library = getLibrary (libraryName);
		
		if (library != null) {
			
			#if flash
			
			if (Std.is (library, Loader)) {
				
				if (symbolName != "") {
					
					return cast (library, Loader).contentLoaderInfo.applicationDomain.getDefinition (symbolName);
					
				} else {
					
					return cast library.contentLoaderInfo.content;
					
				}
				
			}
			
			#end
			
			return library.createMovieClip (symbolName);
			
		}
		
		return null;
		
	}
	
	
	public function getSound (id:String):Sound {
		
		return null;
		
	}
	
	
	public function hasAsset (id:String, type:AssetType):Bool {
		
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
	
	
	public function hasLibrary (name:String, type:String):Bool {
		
		if (type.toLowerCase () == "swf" || type.toLowerCase () == "swf_lite") {
			
			return true;
			
		}
		
		return false;
		
	}
	
	
	public function loadLibrary (name:String, type:String, callback:Dynamic):Void {
		
		if (type.toLowerCase () == "swf") {
			
			#if flash
			
			var loader = new Loader ();
			cachedLoaders.set (name, loader);
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, function (_) {
				
				callback ();
				
			});
			loader.loadBytes (Assets.getBytes("libraries/" + name + ".swf"));
			
			#else
			
			getLibrary (name);
			callback ();
			
			#end
			
		} else {
			
			getLibrary (name);
			callback ();
			
		}
		
	}
	
	
	public function unloadLibrary (name:String, type:String):Void {
		
		if (type.toLowerCase () == "swf") {
			
			#if flash
			
			cachedLoaders.remove (name);
			
			#else
			
			cachedSWFLibraries.remove (name);
			
			#end
		
		} else {
			
			cachedSWFLiteLibraries.remove (name);
			
		}
		
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