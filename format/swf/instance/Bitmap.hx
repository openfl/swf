package format.swf.instance;


import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import format.swf.data.consts.BitmapFormat;
import format.swf.tags.IDefinitionTag;
import format.swf.tags.TagDefineBitsLossless;


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
				
			}
			
			var bitmapData = new BitmapData (data.bitmapWidth, data.bitmapHeight, transparent);
			bitmapData.setPixels (new Rectangle (0, 0, data.bitmapWidth, data.bitmapHeight), buffer);
			
			this.bitmapData = bitmapData;
			
		}
		
	}
	
	
}