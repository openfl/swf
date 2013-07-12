package format.swf.instance;


import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.utils.CompressionAlgorithm;
import format.swf.data.consts.BitmapFormat;
import format.swf.tags.IDefinitionTag;
import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsJPEG3;
import format.swf.tags.TagDefineBitsLossless;
import format.swf.tags.TagDefineBitsJPEG2;

#if flash
import org.bytearray.decoder.JPEGDecoder;
#end


class Bitmap extends flash.display.Bitmap {
	
	
	public function new (tag:IDefinitionTag) {
		
		super ();
		
		if (Std.is (tag, TagDefineBitsLossless)) {
			
			var data:TagDefineBitsLossless = cast tag;
			
			var transparent = (data.level > 1);
			var buffer = data.zlibBitmapData;
			
			try {
				
				buffer.uncompress ();
				
			} catch (e:Dynamic) { }
			
			buffer.position = 0;
			
			if (data.bitmapFormat == BitmapFormat.BIT_8) {
				
				var colorTable = new Array <Int> ();
				
				for (i in 0...data.bitmapColorTableSize) {
					
					var r = buffer.readByte ();
					var g = buffer.readByte ();
					var b = buffer.readByte ();
					
					if (transparent) {
						
						var a = buffer.readByte ();
						colorTable.push ((a << 24) + (r << 16) + (g << 8) + b);
						
					} else {
						
						colorTable.push ((r << 16) + (g << 8) + b);
						
					}
					
				}
				
				var imageData = new ByteArray ();
				var padding = Math.ceil (data.bitmapWidth / 4) - Math.floor (data.bitmapWidth / 4);
				
				for (y in 0...data.bitmapHeight) {
					
					for (x in 0...data.bitmapWidth) {
						
						imageData.writeUnsignedInt (colorTable[buffer.readByte ()]);
						
					}
					
					buffer.position += padding;
					
				}
				
				buffer = imageData;
				buffer.position = 0;
				
			} else {
				
				var newBuffer = new ByteArray ();
				
				for (y in 0...data.bitmapHeight) {
					
					for (x in 0...data.bitmapWidth) {
						
						var a = buffer.readUnsignedByte ();
						var unmultiply = 0xFF / a;
						
						newBuffer.writeByte (a);
						newBuffer.writeByte (Std.int (buffer.readUnsignedByte () * unmultiply));
						newBuffer.writeByte (Std.int (buffer.readUnsignedByte () * unmultiply));
						newBuffer.writeByte (Std.int (buffer.readUnsignedByte () * unmultiply));
						
					}
					
				}
				
				buffer = newBuffer;
				buffer.position = 0;
				
			}
			
			bitmapData = new BitmapData (data.bitmapWidth, data.bitmapHeight, transparent);
			bitmapData.setPixels (bitmapData.rect, buffer);
			
		} else if (Std.is (tag, TagDefineBitsJPEG2)) {
			
			var data:TagDefineBitsJPEG2 = cast tag;
			
			#if flash
			
			var jpeg = new JPEGDecoder (data.bitmapData);
			bitmapData = new BitmapData (jpeg.width, jpeg.height, false);
			bitmapData.setVector (bitmapData.rect, jpeg.pixels);
			
			#else
			
			if (Std.is (tag, TagDefineBitsJPEG3)) {
				
				var alpha = cast (tag, TagDefineBitsJPEG3).bitmapAlphaData;
				
				try {
					
					alpha.uncompress ();
					
				} catch (e:Dynamic) { }
				
				bitmapData = BitmapData.loadFromBytes (data.bitmapData, alpha);
				//bitmapData.unmultiplyAlpha ();
				
				var pixels = bitmapData.getPixels (bitmapData.rect);
				var newPixels = new ByteArray ();
				pixels.position = 0;
				
				var clamp = function (value:Float):Int {
					
					if (value > 0xFF) value = 0xFF;
					if (value < 0) value = 0;
					
					return Std.int (value);
					
				}
				
				for (y in 0...bitmapData.height) {
					
					for (x in 0...bitmapData.width) {
						
						var a = pixels.readUnsignedByte ();
						var unmultiply = 0xFF / a;
						
						newPixels.writeByte (a);
						newPixels.writeByte (clamp (pixels.readUnsignedByte () * unmultiply));
						newPixels.writeByte (clamp (pixels.readUnsignedByte () * unmultiply));
						newPixels.writeByte (clamp (pixels.readUnsignedByte () * unmultiply));
						
					}
					
				}
				
				newPixels.position = 0;
				bitmapData.setPixels (bitmapData.rect, newPixels);
				
			} else {
				
				bitmapData = BitmapData.loadFromBytes (data.bitmapData, null);
				
			}
			
			#end
			
			
			
			
			//var buffer:ByteArray = null;
			//var alpha:ByteArray = null;
			//
			//if (version == 1 && jpegTables != null) {
				//
				//buffer = jpegTables;
				//
			//} else if (version == 2) {
				//
				//var size = stream.getBytesLeft ();
				//buffer = stream.readBytes (size);
				//
			//} else if (version == 3) {
				//
				//var size = stream.readInt ();
				//buffer = stream.readBytes (size);
				//
				//alpha = stream.readFlashBytes (stream.getBytesLeft ());
				//alpha.uncompress ();
				//
			//}
			
			//#if flash
			//
			//loader = new Loader ();
			//this.alpha = alpha;
			//
			//loader.contentLoaderInfo.addEventListener (Event.COMPLETE, loader_onComplete);
			//loader.loadBytes (buffer);
			//
			//#else
			
			
		} else if (Std.is (tag, TagDefineBits)) {
			
			var data:TagDefineBits = cast tag;
			
			#if flash
			
			var jpeg = new JPEGDecoder (data.bitmapData);
			bitmapData = new BitmapData (jpeg.width, jpeg.height, false);
			bitmapData.setVector (bitmapData.rect, jpeg.pixels);
			
			#else
			
			bitmapData = BitmapData.loadFromHaxeBytes (data.bitmapData, null);
			
			#end
			
		}
		
	}
	
	
}