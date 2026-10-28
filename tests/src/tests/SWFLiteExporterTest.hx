package tests;

import openfl.utils.ByteArray;
import swf.data.consts.SoundCompression;
import swf.data.consts.SoundRate;
import swf.data.consts.SoundSize;
import swf.exporters.SWFLiteExporter;
import swf.tags.TagDefineSound;
import utest.Assert;
import utest.Test;

class SWFLiteExporterTest extends Test
{
	#if !flash
	public function testSymbolClassZeroIsRoot():Void
	{
		// the document class is linked to character 0, and is not always named *_fla.MainTimeline
		var exporter = new SWFLiteExporter(new SWFBuilder().link(0, "MainDocument").parse());
		Assert.equals("MainDocument", exporter.swfLite.root.className);
	}

	public function testLinkedSoundClassNames():Void
	{
		var data = new ByteArray();
		for (i in 0...16)
		{
			data.writeByte(i);
		}

		var swf = new SWFBuilder()
			.add(TagDefineSound.create(1, SoundCompression.UNCOMPRESSED_LITTLE_ENDIAN, SoundRate.KHZ_11, SoundSize.BIT_16, swf.data.consts.SoundType.MONO, 8, data))
			.add(TagDefineSound.create(2, SoundCompression.SPEEX, SoundRate.KHZ_5, SoundSize.BIT_16, swf.data.consts.SoundType.MONO, 8, data))
			.link(1, "TestSound")
			.link(2, "TestSpeex")
			.parse();

		var exporter = new SWFLiteExporter(swf);
		Assert.equals("TestSound", exporter.soundSymbolClassNames.get(1));
		Assert.equals("TestSpeex", exporter.soundSymbolClassNames.get(2));
		Assert.equals("UNCOMPRESSED_LITTLE_ENDIAN", Std.string(exporter.soundTypes.get(1)));
		Assert.equals("SPEEX", Std.string(exporter.soundTypes.get(2)));
	}
	#end
}
