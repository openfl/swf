/**
 * __    ___  __ ___   ___                   _           
   \ \  / _ \/__\ _ \ /   \___  ___ ___   __| | ___ _ __ 
    \ \/ /_)/_\/ /_\// /\ / _ \/ __/ _ \ / _` |/ _ \ '__|
 /\_/ / ___//__ /_\\/ /_//  __/ (__ (_) | (_| |  __/ |   
 \___/\/   \__\____/___,' \___|\___\___/ \__,_|\___|_|
 
 * This class lets you decode a JPEG stream in ActionScript 3 in Flash Player 10
 * @author Thibault Imbert (bytearray.org)
 * @version 0.2 - Removed unuseful setters.
 * @version 0.3 - If needed, stream can now be passed when JPEGDecoder is instanciated.
 * @version 0.4 - Check file header before processing it.
 */

package org.bytearray.decoder;

import cmodule.jpegdecoder.CLibInit;
import flash.display.BitmapData;

import flash.errors.Error;
import flash.utils.ByteArray;
import flash.utils.Object;
import flash.Vector;

class JPEGDecoder
{
	public var pixels (get, null):Vector<UInt>;
	public var colorComponents (get, null):UInt;
	public var numComponents (get, null):UInt;
	public var height (get, null):UInt;
	public var width (get, null):UInt;
	
	public var bitmapData:BitmapData;
	
	private var loader:CLibInit;
	private var lib:Object;
	private var memory:ByteArray;
	private var infos:Array<Dynamic>;
	private var position:UInt;
	private var length:UInt;
	private var buffer:ByteArray;
	
	private var _pixels:Vector<UInt>;
	private var _width:UInt;
	private var _height:UInt;
	private var _numComponents:UInt;
	private var _colorComponents:UInt;
	
	public static inline var HEADER:Int = 0xFFD8;
	
	public function new ( stream:ByteArray=null )
	{
		buffer = new ByteArray();
		if ( stream != null ) parse( stream );
	}
	
	/**
	 * Allows you to inject a JPEG stream to decode it. 
	 * @param stream
	 * @return 
	 */		
	public function parse ( stream:ByteArray ):Vector<UInt>
	{
		stream.position = 0;
		if ( stream.readUnsignedShort() != JPEGDecoder.HEADER )
			throw new Error ("Not a valid JPEG file.");
		loader = new CLibInit();
		loader.supplyFile("stream", stream);
		lib = loader.init();
		
		memory = untyped __global__["cmodule.jpegdecoder.gstate"].ds;
		infos = lib.parseJPG ("stream");
		
		_width = infos[0];
		_height = infos[1];
		_numComponents = infos[2];
		_colorComponents = infos[3];
		position = infos[4];
		length = width*height*3;
		
		buffer.length = 0;
		buffer.writeBytes(memory, position, length);
		buffer.position = 0;
		
		var lng:UInt = buffer.length;
		_pixels = new Vector<UInt> (Std.int (lng/3), true);
		var count:Int = 0;
		var i:UInt = 0;
		
		while (i < lng) {
			
			pixels[count++] = (255 << 24 | buffer[i] << 16 | buffer[i+1] << 8 | buffer[i+2]);
			i += 3;
			
		}
		
		bitmapData = new BitmapData (width, height, false);
		bitmapData.setVector (bitmapData.rect, pixels);
		
		return pixels;
	}

	public function get_pixels():Vector<UInt>
	{
		return _pixels;
	}

	public function get_colorComponents():UInt
	{
		return _colorComponents;
	}

	public function get_numComponents():UInt
	{
		return _numComponents;
	}

	public function get_height():UInt
	{
		return _height;
	}

	public function get_width():UInt
	{
		return _width;
	}
}