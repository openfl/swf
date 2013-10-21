package;


import flash.utils.ByteArray;
import format.swf.exporters.SWFLiteExporter;
import format.swf.library.SWFLibrary;
import format.swf.lite.library.SWFLiteLibrary;
import format.swf.lite.symbols.BitmapSymbol;
import format.SWF;
import haxe.io.Path;
import haxe.Serializer;
import haxe.Unserializer;
import helpers.PlatformHelper;
import helpers.StringHelper;
import openfl.Assets;
import project.Architecture;
import project.Asset;
import project.AssetEncoding;
import project.OpenFLProject;
import project.Platform;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;


class Tools {
	
	
	#if (neko && (haxe_210 || haxe3))
	public static function __init__ () {
		
		var haxePath = Sys.getEnv ("HAXEPATH");
		var command = (haxePath != null && haxePath != "") ? haxePath + "/haxelib" : "haxelib";
		
		var process = new Process (command, [ "path", "openfl-tools" ]);
		var path = "";
		
		try {
			
			var lines = new Array <String> ();
			
			while (true) {
				
				var length = lines.length;
				var line = process.stdout.readLine ();
				
				if (length > 0 && StringTools.trim (line) == "-D openfl-tools") {
					
					path = StringTools.trim (lines[length - 1]);
					
				}
				
				lines.push (line);
         		
   			}
   			
		} catch (e:Dynamic) {
			
			process.close ();
			
		}
		
		path += "/ndll/";
		
		switch (PlatformHelper.hostPlatform) {
			
			case WINDOWS:
				
				untyped $loader.path = $array (path + "Windows/", $loader.path);
				
			case MAC:
				
				untyped $loader.path = $array (path + "Mac/", $loader.path);
				untyped $loader.path = $array (path + "Mac64/", $loader.path);
				
			case LINUX:
				
				var arguments = Sys.args ();
				var raspberryPi = false;
				
				for (argument in arguments) {
					
					if (argument == "-rpi") raspberryPi = true;
					
				}
				
				if (raspberryPi) {
					
					untyped $loader.path = $array (path + "RPi/", $loader.path);
					
				} else if (PlatformHelper.hostArchitecture == Architecture.X64) {
					
					untyped $loader.path = $array (path + "Linux64/", $loader.path);
					
				} else {
					
					untyped $loader.path = $array (path + "Linux/", $loader.path);
					
				}
			
			default:
			
		}
		
	}
	#end
	
	
	public static function main () {
		
		var arguments = Sys.args ();
		
		if (arguments.length > 0) {
			
			// When the command-line tools are called from haxelib, 
			// the last argument is the project directory and the
			// path SWF is the current working directory 
			
			var lastArgument = "";
			
			for (i in 0...arguments.length) {
				
				lastArgument = arguments.pop ();
				if (lastArgument.length > 0) break;
				
			}
			
			lastArgument = new Path (lastArgument).toString ();
			
			if (((StringTools.endsWith (lastArgument, "/") && lastArgument != "/") || StringTools.endsWith (lastArgument, "\\")) && !StringTools.endsWith (lastArgument, ":\\")) {
				
				lastArgument = lastArgument.substr (0, lastArgument.length - 1);
				
			}
			
			if (FileSystem.exists (lastArgument) && FileSystem.isDirectory (lastArgument)) {
				
				Sys.setCwd (lastArgument);
				
			}
			
		}
		
		if (arguments.length > 1 && arguments[0] == "process") {
			
			try {
				
				var path = arguments[1];
				var projectData = File.getContent (path);
				
				var unserializer = new Unserializer (projectData);
				unserializer.setResolver (cast { resolveEnum: Type.resolveEnum, resolveClass: resolveClass });
				
				var project:OpenFLProject = unserializer.unserialize ();
				processLibraries (project);
				
			} catch (e:Dynamic) {}
			
		}
		
	}
	
	
	private static function processLibraries (project:OpenFLProject):Void {
		
		var output = new OpenFLProject ();
		var embeddedSWF = false;
		var embeddedSWFLite = false;
		
		for (library in project.libraries) {
			
			var type = library.type;
			
			if (type == null) {
				
				type = Path.extension (library.sourcePath).toLowerCase ();
				
				if (type == "swf" && project.target == Platform.HTML5) {
					
					type = "swflite";
					
				}
				
			}
			
			if (type == "swf") {
				
				var swf = new Asset (library.sourcePath, "libraries/" + library.name + ".swf", AssetType.BINARY);
				
				if (library.embed != null) {
					
					swf.embed = library.embed;
					
				}
				
				output.assets.push (swf);
				
				var data = new SWFLibrary ("libraries/" + library.name + ".swf");
				var asset = new Asset ("", "libraries/" + library.name + ".dat", AssetType.TEXT);
				asset.data = Serializer.run (data);
				output.assets.push (asset);
				
				embeddedSWF = true;
				//project.haxelibs.push (new Haxelib ("swf"));
				//output.assets.push (new Asset (library.sourcePath, "libraries/" + library.name + ".swf", AssetType.BINARY));
				
			} else if (type == "swf_lite" || type == "swflite") {
				
				//project.haxelibs.push (new Haxelib ("swf"));
				
				var bytes = ByteArray.readFile (library.sourcePath);
				var swf = new SWF (bytes);
				var exporter = new SWFLiteExporter (swf.data);
				var swfLite = exporter.swfLite;
				
				for (id in exporter.bitmaps.keys ()) {
					
					var bitmapData = exporter.bitmaps.get (id);
					var symbol:BitmapSymbol = cast swfLite.symbols.get (id);
					symbol.path = "libraries/bin/" + id + ".png";
					swfLite.symbols.set (id, symbol);
					
					var asset = new Asset ("", symbol.path, AssetType.IMAGE);
					//asset.data = StringHelper.base64Encode (bitmapData.encode ("png"));
					asset.data = bitmapData.encode ("png");
					//asset.encoding = AssetEncoding.BASE64;
					output.assets.push (asset);
					
				}
				
				var data = new SWFLiteLibrary (swfLite);
				
				var asset = new Asset ("", "libraries/" + library.name + ".dat", AssetType.TEXT);
				asset.data = Serializer.run (data);
				output.assets.push (asset);
				
				embeddedSWFLite = true;
				
			}
			
		}
		
		if (embeddedSWF) {
			
			output.haxeflags.push ("--macro include('format.swf.library')");
			output.haxeflags.push ("--remap flash:flash");
			
		}
		
		if (embeddedSWFLite) {
			
			output.haxeflags.push ("--macro include('format.swf.lite.library')");
			output.haxeflags.push ("--remap flash:flash");
			
		}
		
		if (output.assets.length > 0) {
			
			Sys.print (Serializer.run (output));
			
		}
		
	}
	
	
	private static function resolveClass (name:String):Class <Dynamic> {
		
		var result = Type.resolveClass (name);
		
		if (result == null) {
			
			result = OpenFLProject;
			
		}
		
		return result;
		
	}
	
	
}