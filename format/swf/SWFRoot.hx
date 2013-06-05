package format.swf;

import format.swf.data.SWFRectangle;
import format.swf.events.SWFProgressEvent;
import flash.utils.ByteArray;
import flash.utils.CompressionAlgorithm;
import flash.errors.Error;


class SWFRoot extends SWFTimelineContainer
{
	public var version:Int;
	public var fileLength:Int;
	public var fileLengthCompressed:Int;
	public var frameSize:SWFRectangle;
	public var frameRate:Float;
	public var frameCount:Int;
	
	public var compressed:Bool;
	public var compressionMethod:CompressionAlgorithm;
	
	private var bytes:SWFData;
	
	private static inline var FILE_LENGTH_POS:Int = 4;
	private static inline var COMPRESSION_START_POS:Int = 8;
	
	public function new(ba:ByteArray = null) {
		super ();
		bytes = new SWFData();
		if (ba != null) {
			loadBytes(ba);
		} else {
			version = 10;
			fileLength = 0;
			fileLengthCompressed = 0;
			frameSize = new SWFRectangle();
			frameRate = 50;
			frameCount = 1;
			compressed = true;
			compressionMethod = CompressionAlgorithm.ZLIB;
		}
	}
	
	public function loadBytes(ba:ByteArray):Void {
		bytes = new SWFData ();
		ba.position = 0;
		ba.readBytes(bytes);
		parse(bytes);
	}
	
	public function loadBytesAsync(ba:ByteArray):Void {
		bytes = new SWFData ();
		ba.position = 0;
		ba.readBytes(bytes);
		parseAsync(bytes);
	}
	
	public function parse(data:SWFData):Void {
		bytes = data;
		parseHeader();
		parseTags(data, version);
	}
	
	public function parseAsync(data:SWFData):Void {
		bytes = data;
		parseHeader();
		parseTagsAsync(data, version);
	}
	
	public function publish(ba:ByteArray):Void {
		var data:SWFData = new SWFData();
		publishHeader(data);
		publishTags(data, version);
		publishFinalize(data);
		ba.writeBytes(data);
	}
	
	public function publishAsync(ba:ByteArray):Void {
		var data:SWFData = new SWFData();
		publishHeader(data);
		publishTagsAsync(data, version);
		addEventListener(SWFProgressEvent.COMPLETE, function(event:SWFProgressEvent):Void {
			removeEventListener(SWFProgressEvent.COMPLETE, this);
			publishFinalize(data);
			ba = new SWFData ();
			ba.writeBytes(data);
		}, false);
	}
	
	private function parseHeader():Void {
		compressed = false;
		compressionMethod = CompressionAlgorithm.ZLIB;
		bytes.position = 0;
		var signatureByte:Int = bytes.readUI8();
		if (signatureByte == 0x43) {
			compressed = true;
		} else if (signatureByte == 0x5A) {
			compressed = true;
			compressionMethod = CompressionAlgorithm.LZMA;
		} else if (signatureByte != 0x46) {
			throw(new Error("Not a SWF. First signature byte is 0x" + StringTools.hex (signatureByte) + " (expected: 0x43 or 0x5A or 0x46)"));
		}
		signatureByte = bytes.readUI8();
		if (signatureByte != 0x57) {
			throw(new Error("Not a SWF. Second signature byte is 0x" + StringTools.hex (signatureByte) + " (expected: 0x57)"));
		}
		signatureByte = bytes.readUI8();
		if (signatureByte != 0x53) {
			throw(new Error("Not a SWF. Third signature byte is 0x" + StringTools.hex (signatureByte) + " (expected: 0x53)"));
		}
		version = bytes.readUI8();
		fileLength = bytes.readUI32();
		fileLengthCompressed = bytes.length;
		if (compressed) {
			// The following data (up to end of file) is compressed, if header has CWS or ZWS signature
			bytes.swfUncompress(compressionMethod, fileLength);
		}
		frameSize = bytes.readRECT();
		frameRate = bytes.readFIXED8();
		frameCount = bytes.readUI16();
	}
	
	private function publishHeader(data:SWFData):Void {
		var firstHeaderByte:Int = 0x46;
		if(compressed) {
			if (compressionMethod == CompressionAlgorithm.ZLIB) {
				firstHeaderByte = 0x43;
			} else if (compressionMethod == CompressionAlgorithm.LZMA) {
				firstHeaderByte = 0x5A;
			}
		}
		data.writeUI8(firstHeaderByte);
		data.writeUI8(0x57);
		data.writeUI8(0x53);
		data.writeUI8(version);
		data.writeUI32(0);
		data.writeRECT(frameSize);
		data.writeFIXED8(frameRate);
		data.writeUI16(frameCount); // TODO: get the real number of frames from the tags
	}

	private function publishFinalize(data:SWFData):Void {
		fileLength = fileLengthCompressed = data.length;
		if (compressed) {
			compressionMethod = CompressionAlgorithm.ZLIB; // Force ZLIB compression. LZMA doesn't seem to work when publishing.
			data.position = COMPRESSION_START_POS;
			data.swfCompress(compressionMethod);
			fileLengthCompressed = data.length;
		}
		var endPos:Int = data.position;
		data.position = FILE_LENGTH_POS;
		data.writeUI32(fileLength);
		data.position = 0;
	}

	override public function toString(indent:Int = 0):String {
		var s:String = "[SWF]\n" +
			"  Header:\n" +
			"    Version: " + version + "\n" +
			"    Compression: ";
		if(compressed) {
			if(compressionMethod == CompressionAlgorithm.ZLIB) {
				s += "ZLIB";
			} else if(compressionMethod == CompressionAlgorithm.LZMA) {
				s += "LZMA";
			} else {
				s += "Unknown";
			}
		} else {
			s += "None";
		}
		return s + "\n    FileLength: " + fileLength + "\n" +
			"    FileLengthCompressed: " + fileLengthCompressed + "\n" +
			"    FrameSize: " + frameSize.toStringSize() + "\n" +
			"    FrameRate: " + frameRate + "\n" +
			"    FrameCount: " + frameCount +
			super.toString(indent);
	}
}