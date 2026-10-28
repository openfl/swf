package tests;

import haxe.Json;
import haxe.crypto.Crc32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.zip.Entry;
import haxe.zip.Writer;
import lime.media.AudioBuffer;
import openfl.utils.AssetType;
import swf.exporters.animate.AnimateLibrary;
import utest.Assert;
import utest.Async;
import utest.Test;

@:access(lime.utils.AssetLibrary)
@:access(swf.exporters.animate.AnimateLibrary)
class AnimateLibraryTest extends Test
{
	public function testLibraryWithoutUUID():Void
	{
		var library = new AnimateLibrary("animate-library-test");
		Assert.equals(library, AnimateLibrary.get("animate-library-test"));

		library.unload();
		Assert.isNull(AnimateLibrary.get("animate-library-test"));
	}

	public function testLinkedSoundLookup():Void
	{
		var library = new AnimateLibrary("animate-library-sound-test");
		var buffer = new AudioBuffer();
		library.soundClassNames.set("TestSound", "sounds/1.wav");
		library.cachedAudioBuffers.set("sounds/1.wav", buffer);
		library.symbols = new Map();
		library.symbolsByClassName = new Map();
		library.bitmapSymbols = [];

		Assert.equals(buffer, library.getAudioBuffer("TestSound"));
		Assert.isTrue(library.exists("TestSound", cast AssetType.SOUND));
		Assert.isTrue(library.exists("TestSound", cast AssetType.MUSIC));
		Assert.isTrue(library.exists("TestSound", null));
		Assert.isFalse(library.exists("TestSound", cast AssetType.MOVIE_CLIP));
		Assert.isFalse(library.exists("TestSound", cast AssetType.IMAGE));

		var loaded:AudioBuffer = null;
		library.loadAudioBuffer("TestSound").onComplete(function(value) loaded = value);
		Assert.equals(buffer, loaded);

		library.unload();
	}

	#if !flash
	public function testBundledSoundBytesAreDecoded():Void
	{
		// on HTML5, Lime leaves bundled sounds as bytes
		var library = new AnimateLibrary("animate-library-bytes-test");
		library.soundClassNames.set("TestSound", "sounds/1.wav");
		library.cachedBytes.set("sounds/1.wav", createWAV());

		assertDecodedWAV(library.getAudioBuffer("TestSound"));
		Assert.isFalse(library.cachedBytes.exists("sounds/1.wav"));

		library.unload();
	}

	public function testLoadLinkedSound(async:Async):Void
	{
		var data = {
			version: 0.1,
			frameRate: 24,
			root: -1,
			uuid: "animate-library-load-test",
			symbols: ([
				{type: 7, id: 1, className: "TestSound", path: "sounds/1.wav"},
				// unknown symbol types are skipped, without registering the previous symbol again
				{type: 99, id: 2, className: "Unknown"}
			] : Array<Dynamic>)
		};
		var manifest = {
			name: null,
			rootPath: null,
			version: 3,
			libraryType: "swf.exporters.animate.AnimateLibrary",
			libraryArgs: ["data.json", "animate-library-load-test"],
			assets: [{path: "data.json", type: "TEXT"}, {path: "sounds/1.wav", type: "SOUND"}]
		};

		var zip = createZip([
			"library.json" => Bytes.ofString(Json.stringify(manifest)),
			"data.json" => Bytes.ofString(Json.stringify(data)),
			"sounds/1.wav" => createWAV()
		]);

		AnimateLibrary.loadFromBytes(zip).onComplete(function(value)
		{
			var library:AnimateLibrary = cast value;
			assertDecodedWAV(library.getAudioBuffer("TestSound"));
			Assert.isTrue(library.exists("TestSound", cast AssetType.SOUND));
			Assert.isFalse(library.symbolsByClassName.exists("TestSound"));
			Assert.isFalse(library.symbolsByClassName.exists("Unknown"));
			Assert.isFalse(library.symbols.exists(2));
			library.unload();
			async.done();
		}).onError(function(error)
		{
			Assert.fail("Could not load library: " + error);
			async.done();
		});
	}

	private static function assertDecodedWAV(buffer:AudioBuffer):Void
	{
		Assert.notNull(buffer);
		#if (js && html5)
		// Howler plays the sound on HTML5, and does not expose its samples
		Assert.notNull(buffer.src);
		#else
		Assert.equals(11025, buffer.sampleRate);
		Assert.equals(1, buffer.channels);
		#end
	}

	private static function createWAV():Bytes
	{
		var samples = 1102;
		var output = new BytesOutput();
		output.writeString("RIFF");
		output.writeInt32(36 + samples * 2);
		output.writeString("WAVE");
		output.writeString("fmt ");
		output.writeInt32(16);
		output.writeUInt16(1);
		output.writeUInt16(1);
		output.writeInt32(11025);
		output.writeInt32(11025 * 2);
		output.writeUInt16(2);
		output.writeUInt16(16);
		output.writeString("data");
		output.writeInt32(samples * 2);
		for (i in 0...samples)
		{
			output.writeInt16(Std.int(Math.sin(i / 4) * 8000));
		}
		return output.getBytes();
	}

	private static function createZip(files:Map<String, Bytes>):Bytes
	{
		var entries = new List<Entry>();
		for (path in files.keys())
		{
			var bytes = files.get(path);
			entries.add({
				fileName: path,
				fileSize: bytes.length,
				fileTime: Date.now(),
				compressed: false,
				dataSize: 0,
				data: bytes,
				crc32: Crc32.make(bytes)
			});
		}

		var output = new BytesOutput();
		new Writer(output).write(entries);
		return output.getBytes();
	}
	#end
}
