package;


import flash.utils.ByteArray;
import format.swf.exporters.SWFLiteExporter;
import format.swf.lite.symbols.BitmapSymbol;
import format.swf.lite.symbols.SpriteSymbol;
import format.swf.lite.SWFLiteLibrary;
import format.swf.lite.SWFLite;
import format.swf.tags.TagDefineButton2;
import format.swf.SWFLibrary;
import format.swf.SWFTimelineContainer;
import format.SWF;
import haxe.io.Path;
import haxe.Json;
import haxe.Serializer;
import haxe.Template;
import haxe.Unserializer;
import helpers.LogHelper;
import helpers.PathHelper;
import helpers.PlatformHelper;
import helpers.StringHelper;
import project.Architecture;
import project.Asset;
import project.AssetEncoding;
import project.AssetType;
import project.Haxelib;
import project.HXProject;
import project.Platform;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;


class Tools {
	
	
	private static var targetDirectory:String;
	
	
	#if (neko && (haxe_210 || haxe3))
	public static function __init__ () {
		
		var haxePath = Sys.getEnv ("HAXEPATH");
		var command = (haxePath != null && haxePath != "") ? haxePath + "/haxelib" : "haxelib";
		
		var process = new Process (command, [ "path", "lime" ]);
		var path = "";
		
		try {
			
			var lines = new Array <String> ();
			
			while (true) {
				
				var length = lines.length;
				var line = process.stdout.readLine ();
				
				if (length > 0 && StringTools.trim (line) == "-D lime") {
					
					path = StringTools.trim (lines[length - 1]);
					
				}
				
				lines.push (line);
         		
   			}
   			
		} catch (e:Dynamic) {
			
			process.close ();
			
		}
		
		path += "/legacy/ndll/";
		
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
	
	
	private static function generateSWFClasses (project:HXProject, output:HXProject, swfAsset:Asset):Void {
		
		var movieClipTemplate = File.getContent (PathHelper.getHaxelib (new Haxelib ("swf")) + "/templates/swf/MovieClip.mtt");
		var simpleButtonTemplate = File.getContent (PathHelper.getHaxelib (new Haxelib ("swf")) + "/templates/swf/SimpleButton.mtt");
		
		var swf = new SWF (ByteArray.fromBytes (File.getBytes (swfAsset.sourcePath)));
		
		for (className in swf.symbols.keys ()) {
			
			var lastIndexOfPeriod = className.lastIndexOf (".");
			
			var packageName = "";
			var name = "";
			
			if (lastIndexOfPeriod == -1) {
				
				name = className;
				
			} else {
				
				packageName = className.substr (0, lastIndexOfPeriod);
				name = className.substr (lastIndexOfPeriod + 1);
				
			}
			
			packageName = packageName.toLowerCase ();
			name = name.substr (0, 1).toUpperCase () + name.substr (1);
			
			var symbolID = swf.symbols.get (className);
			var templateData = null;
			var symbol = swf.data.getCharacter (symbolID);
			
			if (Std.is (symbol, TagDefineButton2)) {
				
				templateData = simpleButtonTemplate;
				
			} else if (Std.is (symbol, SWFTimelineContainer)) {
				
				templateData = movieClipTemplate;
				
			}
			
			if (templateData != null) {
				
				var context = { PACKAGE_NAME: packageName, CLASS_NAME: name, SWF_ID: swfAsset.id, SYMBOL_ID: symbolID };
				var template = new Template (templateData);
				var targetPath;
				
				if (project.target == IOS) {
					
					targetPath = PathHelper.tryFullPath (targetDirectory) + "/" + project.app.file + "/" + "/haxe";
					
				} else {
					
					targetPath = PathHelper.tryFullPath (targetDirectory) + "/haxe";
					
				}
				
				var templateFile = new Asset ("", PathHelper.combine (targetPath, Path.directory (className.split (".").join ("/"))) + "/" + name + ".hx", AssetType.TEMPLATE);
				templateFile.data = template.execute (context);
				output.assets.push (templateFile);
				
			}
			
		}
		
	}
	
	
	private static function generateSWFLiteClasses (project:HXProject, output:HXProject, swfLite:SWFLite, swfLiteAsset:Asset):Void {
		
		var movieClipTemplate = File.getContent (PathHelper.getHaxelib (new Haxelib ("swf")) + "/templates/swf/lite/MovieClip.mtt");
		var simpleButtonTemplate = File.getContent (PathHelper.getHaxelib (new Haxelib ("swf")) + "/templates/swf/lite/SimpleButton.mtt");
		
		for (symbolID in swfLite.symbols.keys ()) {
			
			var symbol = swfLite.symbols.get (symbolID);
			var templateData = null;
			
			if (Std.is (symbol, SpriteSymbol)) {
				
				templateData = movieClipTemplate;
				
			}
			
			if (templateData != null) {
				
				var lastIndexOfPeriod = symbol.className.lastIndexOf (".");
				
				var packageName = "";
				var name = "";
				
				if (lastIndexOfPeriod == -1) {
					
					name = symbol.className;
					
				} else {
					
					packageName = symbol.className.substr (0, lastIndexOfPeriod);
					name = symbol.className.substr (lastIndexOfPeriod + 1);
					
				}
				
				packageName = packageName.toLowerCase ();
				name = name.substr (0, 1).toUpperCase () + name.substr (1);
				
				var context = { PACKAGE_NAME: packageName, CLASS_NAME: name, SWF_ID: swfLiteAsset.id, SYMBOL_ID: symbolID };
				var template = new Template (templateData);
				var targetPath;
				
				if (project.target == IOS) {
					
					targetPath = PathHelper.tryFullPath (targetDirectory) + "/" + project.app.file + "/" + "/haxe";
					
				} else {
					
					targetPath = PathHelper.tryFullPath (targetDirectory) + "/haxe";
					
				}
				
				var templateFile = new Asset ("", PathHelper.combine (targetPath, Path.directory (symbol.className.split (".").join ("/"))) + "/" + name + ".hx", AssetType.TEMPLATE);
				templateFile.data = template.execute (context);
				output.assets.push (templateFile);
				
			}
			
		}
		
	}
	
	
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
		
		var words = new Array<String> ();
		
		for (arg in arguments) {
			
			if (arg == "-verbose") {
				
				LogHelper.verbose = true;
				
			} else if (arg.substr (0, 2) == "--") {
				
				var equals = arg.indexOf ("=");
				
				if (equals > -1) {
					
					var field = arg.substr (2, equals - 2);
					var argValue = arg.substr (equals + 1);
					
					switch (field) {
						
						case "targetDirectory":
							
							targetDirectory = argValue;
							
						default:
						
					}
					
				}
				
			} else {
				
				words.push (arg);
				
			}
			
		}
		
		if (words.length > 2 && words[0] == "process") {
			
			try {
				
				var inputPath = words[1];
				var outputPath = words[2];
				
				var projectData = File.getContent (inputPath);
				
				var unserializer = new Unserializer (projectData);
				unserializer.setResolver (cast { resolveEnum: Type.resolveEnum, resolveClass: resolveClass });
				var project:HXProject = unserializer.unserialize ();
				
				var output = processLibraries (project);
				
				if (output != null) {
					
					File.saveContent (outputPath, Serializer.run (output));
					
				}
				
			} catch (e:Dynamic) {
				
				LogHelper.error (e);
				
			}
			
		}
		
	}
	
	
	private static function processLibraries (project:HXProject):HXProject {
		
		var output = new HXProject ();
		var embeddedSWF = false;
		var embeddedSWFLite = false;
		//var filterClasses = [];
		
		for (library in project.libraries) {
			
			var type = library.type;
			
			if (type == null) {
				
				type = Path.extension (library.sourcePath).toLowerCase ();
				
				if (type == "swf" && (project.target == Platform.HTML5 || project.target == Platform.FIREFOX)) {
					
					type = "swflite";
					
				}
				
			}
			
			if (type == "swf" && project.target != Platform.HTML5) {
				
				LogHelper.info ("", " - \x1b[1mProcessing library:\x1b[0m " + library.sourcePath + " [SWF]");
				
				var swf = new Asset (library.sourcePath, "libraries/" + library.name + "/" + library.name + ".swf", AssetType.BINARY);
				
				if (library.embed != null) {
					
					swf.embed = library.embed;
					
				}
				
				output.assets.push (swf);
				
				var data:Dynamic = {};
				data.version = 0.1;
				data.type = "format.swf.SWFLibrary";
				data.args = [ "libraries/" + library.name + "/" + library.name + ".swf" ];
				
				var asset = new Asset ("", "libraries/" + library.name + ".json", AssetType.TEXT);
				asset.data = Json.stringify (data);
				output.assets.push (asset);
				
				if (library.generate) {
					
					generateSWFClasses (project, output, swf);
					
				}
				
				embeddedSWF = true;
				//project.haxelibs.push (new Haxelib ("swf"));
				//output.assets.push (new Asset (library.sourcePath, "libraries/" + library.name + ".swf", AssetType.BINARY));
				
			} else if (type == "swf_lite" || type == "swflite") {
				
				LogHelper.info ("", " - \x1b[1mProcessing library:\x1b[0m " + library.sourcePath + " [SWFLite]");
				
				//project.haxelibs.push (new Haxelib ("swf"));
				
				var cacheAvailable = false;
				var cacheDirectory = null;
				
				if (targetDirectory != null) {
					
					cacheDirectory = targetDirectory + "/obj/libraries/" + library.name;
					var cacheFile = cacheDirectory + "/" + library.name + ".dat";
					
					if (FileSystem.exists (cacheFile)) {
						
						var cacheDate = FileSystem.stat (cacheFile).mtime;
						var swfToolDate = FileSystem.stat (PathHelper.getHaxelib (new Haxelib ("swf")) + "/run.n").mtime;
						var sourceDate = FileSystem.stat (library.sourcePath).mtime;
						
						if (sourceDate.getTime () < cacheDate.getTime () && swfToolDate.getTime () < cacheDate.getTime ()) {
							
							cacheAvailable = true;
							
						}
						
					}
					
				}
				
				if (cacheAvailable) {
					
					for (file in FileSystem.readDirectory (cacheDirectory)) {
						
						if (Path.extension (file) == "png") {
							
							var asset = new Asset (cacheDirectory + "/" + file, "libraries/" + library.name + "/" + file, AssetType.IMAGE);
							output.assets.push (asset);
							
						}
						
					}
					
					var swfLiteAsset = new Asset (cacheDirectory + "/" + library.name + ".dat", "libraries/" + library.name + "/" + library.name + ".dat", AssetType.TEXT);
					output.assets.push (swfLiteAsset);
					
					var asset = new Asset (cacheDirectory + ".json", "libraries/" + library.name + ".json", AssetType.TEXT);
					output.assets.push (asset);
					
					embeddedSWFLite = true;
					
				} else {
					
					if (cacheDirectory != null) {
						
						PathHelper.mkdir (cacheDirectory);
						
					}
					
					var bytes = ByteArray.readFile (library.sourcePath);
					var swf = new SWF (bytes);
					var exporter = new SWFLiteExporter (swf.data);
					var swfLite = exporter.swfLite;
					
					for (id in exporter.bitmaps.keys ()) {
						
						var bitmapData = exporter.bitmaps.get (id);
						var symbol:BitmapSymbol = cast swfLite.symbols.get (id);
						symbol.path = "libraries/" + library.name + "/" + id + ".png";
						swfLite.symbols.set (id, symbol);
						
						var asset = new Asset ("", symbol.path, AssetType.IMAGE);
						var assetData = bitmapData.encode ("png");
						
						if (cacheDirectory != null) {
							
							asset.sourcePath = cacheDirectory + "/" + id + ".png";
							asset.format = "png";
							File.saveBytes (asset.sourcePath, assetData);
							
						} else {
							
							asset.data = StringHelper.base64Encode (cast assetData);
							//asset.data = bitmapData.encode ("png");
							asset.encoding = AssetEncoding.BASE64;
							
						}
						
						output.assets.push (asset);
						
					}
					
					//for (filterClass in exporter.filterClasses.keys ()) {
						
						//filterClasses.remove (filterClass);
						//filterClasses.push (filterClass);
						
					//}
					
					var data:Dynamic = {};
					data.version = 0.1;
					data.type = "format.swf.lite.SWFLiteLibrary";
					data.args = [ "libraries/" + library.name + "/" + library.name + ".dat" ];
					
					var swfLiteAsset = new Asset ("", "libraries/" + library.name + "/" + library.name + ".dat", AssetType.TEXT);
					var swfLiteAssetData = swfLite.serialize ();
					
					var asset = new Asset ("", "libraries/" + library.name + ".json", AssetType.TEXT);
					var assetData = Json.stringify (data);
					
					if (cacheDirectory != null) {
						
						swfLiteAsset.sourcePath = cacheDirectory + "/" + library.name + ".dat";
						File.saveContent (swfLiteAsset.sourcePath, swfLiteAssetData);
						
						asset.sourcePath = cacheDirectory + ".json";
						File.saveContent (asset.sourcePath, assetData);
						
					} else {
						
						swfLiteAsset.data = swfLiteAssetData;
						asset.data = assetData;
						
					}
					
					output.assets.push (swfLiteAsset);
					output.assets.push (asset);
					
					if (library.generate) {
						
						generateSWFLiteClasses (project, output, swfLite, swfLiteAsset);
						
					}
					
					embeddedSWFLite = true;
					
				}
				
			}
			
		}
		
		if (embeddedSWF) {
			
			output.haxelibs.push (new Haxelib ("format"));
			output.haxeflags.push ("format.swf.SWFLibrary");
			
		}
		
		if (embeddedSWFLite) {
			
			output.haxeflags.push ("format.swf.lite.SWFLiteLibrary");
			
			//for (filterClass in filterClasses) {
				
				//output.haxeflags.push (StringTools.replace (filterClass, "._v2", ""));
				
			//}
			
		}
		
		if (embeddedSWF || embeddedSWFLite) {
			
			return output;
			
		}
		
		return null;
		
	}
	
	
	private static function resolveClass (name:String):Class <Dynamic> {
		
		var result = Type.resolveClass (name);
		
		if (result == null) {
			
			result = HXProject;
			
		}
		
		return result;
		
	}
	
	
}