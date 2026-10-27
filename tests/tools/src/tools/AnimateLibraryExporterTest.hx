package tools;

import haxe.Json;
import haxe.io.Bytes;
import haxe.zip.Reader;
import hxp.Path;
import lime.tools.Asset;
import openfl.utils.ByteArray;
import swf.SWFRoot;
import swf.data.consts.SoundCompression;
import swf.data.consts.SoundRate;
import swf.data.consts.SoundSize;
import swf.data.consts.SoundType;
import swf.exporters.AnimateLibraryExporter;
import swf.tags.TagDefineShape;
import swf.tags.TagDefineSound;
import sys.FileSystem;
import sys.io.File;
import tests.SWFBuilder;
import tests.ShapeBuilder;
import utest.Assert;
import utest.Test;

@:access(swf.exporters.AnimateLibraryExporter)
class AnimateLibraryExporterTest extends Test
{
	public function testGeneratedClassesAreTemplates():Void
	{
		var exporter = export(new SWFBuilder().add(SWFBuilder.createSprite(1)).link(1, "Clip").parse());

		var output:Array<Asset> = [];
		Assert.same(["Clip"], exporter.generateClasses("generated", output));
		Assert.equals(1, output.length);
		Assert.isTrue(output[0].type == lime.tools.AssetType.TEMPLATE);
	}

	public function testIncludedClassesOnlyDependOnTheLibrary():Void
	{
		// Clip has a child field of type Child, so it depends on Child and on Child's base class
		Assert.same(["Child", "Clip"], getIncludedClasses(null));
		Assert.same([], getIncludedClasses("com.example.Missing"));
		Assert.same(["Child", "Clip"], getIncludedClasses("Clip"));
	}

	public function testSymbolClassZeroIsRoot():Void
	{
		// the document class is linked to character 0, and is not always named *_fla.MainTimeline
		var exporter = export(new SWFBuilder().link(0, "MainDocument").parse());
		Assert.equals("MainDocument", exporter.libraryData.root.className);
	}

	public function testLineGradientStyleIsSerialized():Void
	{
		var tag = new TagDefineShape();
		tag.characterId = 1;
		tag.shapes = new ShapeBuilder()
			.addGradientLine(20, [0xFFFF0000, 0xFF0000FF], [0, 255])
			.move(0, 0, -1, -1, 1)
			.lineTo(1000, 0)
			.end();

		var exporter = export(new SWFBuilder().parse());
		var symbol = exporter.addShape(tag);
		var commands:Array<Dynamic> = symbol.commands;

		// LINE_GRADIENT_STYLE, type, colors, alphas, ratios, matrix, spread, interpolation, focal point
		var index = -1;
		for (i in 0...commands.length - 8)
		{
			if (commands[i] == 9 && Std.isOfType(commands[i + 2], Array))
			{
				index = i;
				break;
			}
		}
		Assert.isTrue(index > -1);
		Assert.same([0xFF0000, 0x0000FF], commands[index + 2]);
		Assert.same([0, 255], commands[index + 4]);
	}

	public function testLinkedSoundExport():Void
	{
		var pcm16 = createPCM(441, 2);
		var pcm8 = createPCM(1001, 1);
		var frames = createMP3Frames();
		var mp3 = new ByteArray();
		// an empty ID3v2 tag, which DefineSound does not keep
		for (value in [0x49, 0x44, 0x33, 3, 0, 0, 0, 0, 0, 0])
		{
			mp3.writeByte(value);
		}
		mp3.writeBytes(frames);

		var path = tempPath("sounds.zip");
		new AnimateLibraryExporter(new SWFBuilder()
			.add(TagDefineSound.create(1, SoundCompression.UNCOMPRESSED_LITTLE_ENDIAN, SoundRate.KHZ_11, SoundSize.BIT_16, SoundType.MONO, 441, pcm16))
			.add(TagDefineSound.create(2, SoundCompression.UNCOMPRESSED_NATIVE_ENDIAN, SoundRate.KHZ_22, SoundSize.BIT_8, SoundType.STEREO, 500, pcm8))
			.add(TagDefineSound.createWithMP3(3, mp3))
			.add(TagDefineSound.create(4, SoundCompression.ADPCM, SoundRate.KHZ_22, SoundSize.BIT_16, SoundType.MONO, 4, createPCM(4, 1)))
			.add(TagDefineSound.create(5, SoundCompression.SPEEX, SoundRate.KHZ_5, SoundSize.BIT_16, SoundType.MONO, 4, createPCM(4, 1)))
			.link(1, "TestSound")
			.link(2, "TestSound8")
			.link(3, "TestMp3")
			.link(4, "TestAdpcm")
			.link(5, "TestSpeex")
			.parse(), path);

		var entries = readZip(path);
		checkWAV(entries.get("sounds/1.wav"), 1, 11025, 16, pcm16.length);
		checkWAV(entries.get("sounds/2.wav"), 2, 22050, 8, pcm8.length);
		var expectedMP3 = Bytes.alloc(frames.length);
		for (i in 0...frames.length)
		{
			expectedMP3.set(i, frames[i]);
		}
		Assert.equals(0, entries.get("sounds/3.mp3").compare(expectedMP3));
		Assert.isFalse(entries.exists("sounds/4.wav"));

		var symbols = new Map<Int, Dynamic>();
		for (symbol in (Json.parse(entries.get("data.json").toString()).symbols : Array<Dynamic>))
		{
			if (symbol != null) symbols.set(symbol.id, symbol);
		}
		Assert.equals("TestSound", symbols.get(1).className);
		Assert.equals("sounds/1.wav", symbols.get(1).path);
		Assert.equals(7, symbols.get(1).type);
		Assert.equals("TestMp3", symbols.get(3).className);
		Assert.isFalse(symbols.exists(4));
		Assert.isFalse(symbols.exists(5));

		var soundAssets = [];
		for (asset in (Json.parse(entries.get("library.json").toString()).assets : Array<Dynamic>))
		{
			if (asset.type == "SOUND") soundAssets.push(asset.path);
		}
		soundAssets.sort(Reflect.compare);
		Assert.same(["sounds/1.wav", "sounds/2.wav", "sounds/3.mp3"], soundAssets);
	}

	private static function getIncludedClasses(childBaseClassName:String):Array<String>
	{
		var exporter = export(new SWFBuilder().parse());
		exporter.libraryData.symbols = new Map();
		exporter.libraryData.symbols.set(1, {type: 5, id: 1, className: "Child", baseClassName: childBaseClassName, frames: []});
		exporter.libraryData.symbols.set(2, {
			type: 5,
			id: 2,
			className: "Clip",
			baseClassName: null,
			frames: [{objects: [{name: "child", symbol: 1}]}]
		});

		var included = [];
		exporter.generateClasses("generated", [], "", included);
		included.sort(Reflect.compare);
		return included;
	}

	private static function export(swf:SWFRoot, path:String = null):AnimateLibraryExporter
	{
		return new AnimateLibraryExporter(swf, path != null ? path : tempPath("library.zip"));
	}

	private static function checkWAV(wav:Bytes, channels:Int, sampleRate:Int, bitsPerSample:Int, dataLength:Int):Void
	{
		Assert.equals("RIFF", wav.getString(0, 4));
		// RIFF chunks are padded to an even length
		Assert.equals(44 + dataLength + dataLength % 2, wav.length);
		Assert.equals(wav.length - 8, wav.getInt32(4));
		Assert.equals("WAVE", wav.getString(8, 4));
		Assert.equals(1, wav.getUInt16(20));
		Assert.equals(channels, wav.getUInt16(22));
		Assert.equals(sampleRate, wav.getInt32(24));
		Assert.equals(sampleRate * channels * Std.int(bitsPerSample / 8), wav.getInt32(28));
		Assert.equals(bitsPerSample, wav.getUInt16(34));
		Assert.equals("data", wav.getString(36, 4));
		Assert.equals(dataLength, wav.getInt32(40));
	}

	private static function createMP3Frames():ByteArray
	{
		// two silent MPEG-1 Layer III frames at 128 kbit/s and 44.1 kHz, 417 bytes each
		var frames = new ByteArray();
		for (frame in 0...2)
		{
			for (value in [0xFF, 0xFB, 0x90, 0x00])
			{
				frames.writeByte(value);
			}
			for (i in 0...413)
			{
				frames.writeByte(0);
			}
		}
		return frames;
	}

	private static function createPCM(length:Int, seed:Int):ByteArray
	{
		var data = new ByteArray();
		for (i in 0...length)
		{
			data.writeByte((i * seed) & 0xFF);
		}
		return data;
	}

	private static function readZip(path:String):Map<String, Bytes>
	{
		var entries = new Map<String, Bytes>();
		var input = File.read(path, true);
		for (entry in Reader.readZip(input))
		{
			entries.set(entry.fileName, entry.compressed ? Reader.unzip(entry) : entry.data);
		}
		input.close();
		return entries;
	}

	public static function tempPath(name:String):String
	{
		var directory = Path.combine(Path.directory(Sys.programPath()), "tmp");
		if (!FileSystem.exists(directory)) FileSystem.createDirectory(directory);
		return Path.combine(directory, name);
	}
}
