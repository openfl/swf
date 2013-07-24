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


class Bitmap extends flash.display.Bitmap {
	
	
	public function new (tag:IDefinitionTag) {
		
		super ();
		
		if (Std.is (tag, TagDefineBitsLossless)) {
			
			var data:TagDefineBitsLossless = cast tag;
			
			if (data.instance != null) {
				
				bitmapData = data.instance;
				
			} else {
				
				var transparent = (data.level > 1);
				var buffer = data.zlibBitmapData;
				buffer.uncompress ();
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
					
					#if flash
					
					var newBuffer = new ByteArray ();
					
					for (y in 0...data.bitmapHeight) {
						
						for (x in 0...data.bitmapWidth) {
							
							var a = buffer.readUnsignedByte ();
							var unmultiply = 255.0 / a;
							
							newBuffer.writeByte (a);
							newBuffer.writeByte (Std.int (buffer.readUnsignedByte () * unmultiply));
							newBuffer.writeByte (Std.int (buffer.readUnsignedByte () * unmultiply));
							newBuffer.writeByte (Std.int (buffer.readUnsignedByte () * unmultiply));
							
						}
						
					}
					
					buffer = newBuffer;
					buffer.position = 0;
					
					#end
					
				}
				
				bitmapData = new BitmapData (data.bitmapWidth, data.bitmapHeight, transparent);
				bitmapData.setPixels (bitmapData.rect, buffer);
				
				#if (cpp || neko)
				bitmapData.unmultiplyAlpha ();
				#end
				
				data.instance = bitmapData;
				
			}
			
		} else if (Std.is (tag, TagDefineBitsJPEG2)) {
			
			var data:TagDefineBitsJPEG2 = cast tag;
			
			if (data.instance != null) {
				
				bitmapData = data.instance;
				
			} else {
				
				#if !flash
				
				if (Std.is (tag, TagDefineBitsJPEG3)) {
					
					var alpha = cast (tag, TagDefineBitsJPEG3).bitmapAlphaData;
					alpha.uncompress ();
					
					bitmapData = BitmapData.loadFromBytes (data.bitmapData, alpha);
					bitmapData.unmultiplyAlpha ();
					
				} else {
					
					bitmapData = BitmapData.loadFromBytes (data.bitmapData, null);
					
				}
				
				data.instance = bitmapData;
				
				#end
				
			}
			
		} /*else if (Std.is (tag, TagDefineBits)) {
			
			var data:TagDefineBits = cast tag;
			
			#if flash
			
			//var jpeg = new JPEGDecoder (data.bitmapData);
			//bitmapData = new BitmapData (jpeg.width, jpeg.height, false);
			//bitmapData.setVector (bitmapData.rect, jpeg.pixels);
			
			#else
			
			bitmapData = BitmapData.loadFromBytes (data.bitmapData, null);
			
			#end
			
		}*/
		
	}
	
	
}