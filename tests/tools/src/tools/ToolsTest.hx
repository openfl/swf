package tools;

import haxe.Json;
import hxp.Path;
import hxp.System;
import lime.tools.Asset;
import lime.tools.AssetType;
import lime.tools.HXProject;
import lime.tools.Library;
import lime.tools.Platform;
import sys.FileSystem;
import sys.io.File;
import tests.SWFBuilder;
import utest.Assert;
import utest.Test;

@:access(Tools)
class ToolsTest extends Test
{
	public function testFlashClassPaths():Void
	{
		var swfPath = writeSWF(createDirectory("flash-paths"), new SWFBuilder()
			.add(SWFBuilder.createSprite(1))
			.add(SWFBuilder.createSprite(2))
			.link(1, "SkyPandaTiles_fla.Clip")
			.link(2, "Plain"));

		// Haxe packages start with a lowercase letter, and the prefix is only added once
		Assert.same(["../haxe/_generated/Plain.hx", "../haxe/_generated/skyPandaTiles_fla/Clip.hx"], getFlashClassPaths(swfPath, ""));
		Assert.same(["../haxe/_generated/LibPlain.hx", "../haxe/_generated/skyPandaTiles_fla/LibClip.hx"], getFlashClassPaths(swfPath, "lib"));
	}

	public function testFlashLibraryCache():Void
	{
		var directory = createDirectory("flash-cache");
		var project = createProject(Platform.FLASH, writeSWF(directory, createClipSWF()), true);
		Tools.targetDirectory = directory;

		var output = Tools.processLibraries(project);
		Assert.isTrue(output.haxeflags.indexOf("Clip") > -1);
		Assert.notNull(findTemplate(output, "Clip.hx"));

		markCachedTemplates(directory);
		var cached = Tools.processLibraries(project);
		Assert.isTrue(cached.haxeflags.indexOf("Clip") > -1);
		Assert.equals("// cached", findTemplate(cached, "Clip.hx").data);

		// a different prefix makes the cache out of date
		project.libraries[0].prefix = "lib";
		var renamed = Tools.processLibraries(project);
		Assert.isTrue(renamed.haxeflags.indexOf("LibClip") > -1);
		Assert.notNull(findTemplate(renamed, "LibClip.hx"));
	}

	public function testAnimateGeneratedClassesAreCompiled():Void
	{
		var directory = createDirectory("animate-generate");
		var project = createProject(Platform.HTML5, writeSWF(directory, createClipSWF()), true);
		Tools.targetDirectory = directory;

		var output = Tools.processLibraries(project);
		Assert.isTrue(output.haxeflags.indexOf("Clip") > -1);
		Assert.notNull(findTemplate(output, "Clip.hx"));

		// templates come back from the cache, otherwise Lime would delete them as stale files
		markCachedTemplates(directory);
		var cached = Tools.processLibraries(project);
		Assert.isTrue(cached.haxeflags.indexOf("Clip") > -1);
		Assert.equals("// cached", findTemplate(cached, "Clip.hx").data);

		// classes are only compiled when generate="true"
		project.libraries[0].generate = null;
		var unset = Tools.processLibraries(project);
		Assert.equals(-1, unset.haxeflags.indexOf("Clip"));
		Assert.notNull(findTemplate(unset, "Clip.hx"));

		project.libraries[0].generate = false;
		var disabled = Tools.processLibraries(project);
		Assert.equals(-1, disabled.haxeflags.indexOf("Clip"));
		Assert.isNull(findTemplate(disabled, "Clip.hx"));
	}

	private static function createClipSWF():SWFBuilder
	{
		return new SWFBuilder().add(SWFBuilder.createSprite(1)).link(1, "Clip");
	}

	private static function createProject(target:Platform, swfPath:String, generate:Null<Bool>):HXProject
	{
		var project = new HXProject();
		project.target = target;
		project.libraries.push(new Library(swfPath, "lib", "swf", true, false, generate, ""));
		return project;
	}

	private static function createDirectory(name:String):String
	{
		var directory = AnimateLibraryExporterTest.tempPath(name);
		if (FileSystem.exists(directory)) System.removeDirectory(directory);
		System.mkdir(directory);
		return directory;
	}

	private static function findTemplate(project:HXProject, fileName:String):Asset
	{
		for (asset in project.assets)
		{
			if (asset.type == AssetType.TEMPLATE && Path.withoutDirectory(asset.targetPath) == fileName)
			{
				return asset;
			}
		}
		return null;
	}

	private static function getFlashClassPaths(swfPath:String, prefix:String):Array<String>
	{
		var output = new HXProject();
		Tools.generateSWFClasses(new HXProject(), output, new Asset(swfPath, "library.swf", AssetType.BINARY), prefix);

		var paths = [for (asset in output.assets) StringTools.replace(asset.targetPath, "\\", "/")];
		paths.sort(Reflect.compare);
		return paths;
	}

	private static function markCachedTemplates(directory:String):Void
	{
		// so the next build can tell whether the templates came from the cache
		var cacheFile = Path.combine(directory, "obj/libraries/lib.classes.json");
		Assert.isTrue(FileSystem.exists(cacheFile));

		var cache:Dynamic = Json.parse(File.getContent(cacheFile));
		for (template in (cache.templates : Array<Dynamic>))
		{
			template.data = "// cached";
		}
		File.saveContent(cacheFile, Json.stringify(cache));
	}

	private static function writeSWF(directory:String, swf:SWFBuilder):String
	{
		var path = Path.combine(directory, "library.swf");
		File.saveBytes(path, swf.build());
		// caches are only used when they are newer than the SWF file
		Sys.sleep(1.1);
		return path;
	}
}
