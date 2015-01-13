package format.swf;


import flash.errors.Error;
import flash.utils.ByteArray;
import flash.utils.CompressionAlgorithm;
import flash.utils.Endian;
import format.swf.data.actions.IAction;
import format.swf.factories.SWFActionFactory;
import format.swf.factories.SWFFilterFactory;
import format.swf.data.filters.IFilter;
import format.swf.utils.HalfPrecisionWriter;
//import format.swf.data.SWFActionValue;
import format.swf.data.SWFButtonCondAction;
import format.swf.data.SWFButtonRecord;
import format.swf.data.SWFClipActionRecord;
import format.swf.data.SWFClipActions;
import format.swf.data.SWFClipEventFlags;
import format.swf.data.SWFColorTransform;
import format.swf.data.SWFColorTransformWithAlpha;
import format.swf.data.SWFFillStyle;
import format.swf.data.SWFFocalGradient;
import format.swf.data.SWFGlyphEntry;
import format.swf.data.SWFGradient;
import format.swf.data.SWFGradientRecord;
import format.swf.data.SWFKerningRecord;
import format.swf.data.SWFLineStyle;
import format.swf.data.SWFLineStyle2;
import format.swf.data.SWFMatrix;
import format.swf.data.SWFMorphFillStyle;
import format.swf.data.SWFMorphFocalGradient;
import format.swf.data.SWFMorphGradient;
import format.swf.data.SWFMorphGradientRecord;
import format.swf.data.SWFMorphLineStyle;
import format.swf.data.SWFMorphLineStyle2;
import format.swf.data.SWFRawTag;
import format.swf.data.SWFRecordHeader;
import format.swf.data.SWFRectangle;
import format.swf.data.SWFRegisterParam;
import format.swf.data.SWFShape;
import format.swf.data.SWFShapeRecordCurvedEdge;
import format.swf.data.SWFShapeRecordStraightEdge;
import format.swf.data.SWFShapeRecordStyleChange;
import format.swf.data.SWFShapeWithStyle;
import format.swf.data.SWFSoundEnvelope;
import format.swf.data.SWFSoundInfo;
import format.swf.data.SWFSymbol;
import format.swf.data.SWFTextRecord;
import format.swf.data.SWFZoneData;
import format.swf.data.SWFZoneRecord;
import format.swf.utils.BitArray;

#if haxe3
typedef Hash<T> = Map<String, T>;
typedef IntHash<T> = Map<Int, T>;
#end


class SWFData extends BitArray
{
	public static inline var FLOAT16_EXPONENT_BASE:Float = 15;
	#if flash
	public static var MIN_FLOAT_VALUE:Float = untyped __global__ ["Number"].MIN_VALUE;
	public static var MAX_FLOAT_VALUE:Float = untyped __global__ ["Number"].MAX_VALUE;
	#elseif js
	public static var MIN_FLOAT_VALUE:Float = untyped __js__ ("Number.MIN_VALUE");
	public static var MAX_FLOAT_VALUE:Float = untyped __js__ ("Number.MAX_VALUE");
	#else
    public static inline var MIN_FLOAT_VALUE:Float = 2.2250738585072014e-308;
    public static inline var MAX_FLOAT_VALUE:Float = 1.7976931348623158e+308;
	#end
	
	public function new() {
		
		super ();
		endian = Endian.LITTLE_ENDIAN;
		
	}

	/////////////////////////////////////////////////////////
	// Integers
	/////////////////////////////////////////////////////////
	
	public function readSI8():Int {
		resetBitsPending();
		return readByte();
	}
	
	public function writeSI8(value:Int):Void {
		resetBitsPending();
		writeByte(value);
	}

	public function readSI16():Int {
		resetBitsPending();
		return readShort();
	}
	
	public function writeSI16(value:Int):Void {
		resetBitsPending();
		writeShort(value);
	}

	public function readSI32():Int {
		resetBitsPending();
		return readInt();
	}
	
	public function writeSI32(value:Int):Void {
		resetBitsPending();
		writeInt(value);
	}

	public function readUI8():Int {
		resetBitsPending();
		return readUnsignedByte();
	}
	
	public function writeUI8(value:Int):Void {
		resetBitsPending();
		writeByte(value);
	}

	public function readUI16():Int {
		resetBitsPending();
		return readUnsignedShort();
	}
	
	public function writeUI16(value:Int):Void {
		resetBitsPending();
		writeShort(value);
	}

	public function readUI24():Int {
		resetBitsPending();
		var loWord:Int = readUnsignedShort();
		var hiByte:Int = readUnsignedByte();
		return (hiByte << 16) | loWord;
	}
	
	public function writeUI24(value:Int):Void {
		resetBitsPending();
		writeShort(value & 0xffff);
		writeByte(value >> 16);
	}
	
	public function readUI32():Int {
		resetBitsPending();
		return readUnsignedInt();
	}
	
	public function writeUI32(value:Int):Void {
		resetBitsPending();
		writeUnsignedInt(value);
	}
	
	/////////////////////////////////////////////////////////
	// Fixed-point numbers
	/////////////////////////////////////////////////////////
	
	public function readFIXED():Float {
		resetBitsPending();
		return readInt() / 65536;
	}
	
	public function writeFIXED(value:Float):Void {
		resetBitsPending();
		writeInt(Std.int(value * 65536));
	}

	public function readFIXED8():Float {
		resetBitsPending();
		return readShort() / 256;
	}

	public function writeFIXED8(value:Float):Void {
		resetBitsPending();
		writeShort(Std.int(value * 256));
	}

	/////////////////////////////////////////////////////////
	// Floating-point numbers
	/////////////////////////////////////////////////////////
	
	public function readFLOAT():Float {
		resetBitsPending();
		return readFloat();
	}
	
	public function writeFLOAT(value:Float):Void {
		resetBitsPending();
		writeFloat(value);
	}

	public function readDOUBLE():Float {
		resetBitsPending();
		return readDouble();
	}

	public function writeDOUBLE(value:Float):Void {
		resetBitsPending();
		writeDouble(value);
	}

	public function readFLOAT16():Float {
		resetBitsPending();
		var word:Int = readUnsignedShort();
		var sign:Int = ((word & 0x8000) != 0) ? -1 : 1;
		var exponent:Int = (word >> 10) & 0x1f;
		var significand:Int = word & 0x3ff;
		if (exponent == 0) {
			if (significand == 0) {
				return 0;
			} else {
				// subnormal number
				return sign * Math.pow(2, 1 - FLOAT16_EXPONENT_BASE) * (significand / 1024);
			}
		}
		if (exponent == 31) { 
			if (significand == 0) {
				return (sign < 0) ? Math.NEGATIVE_INFINITY : Math.POSITIVE_INFINITY;
			} else {
				return Math.NaN;
			}
		}
		// normal number
		return sign * Math.pow(2, exponent - FLOAT16_EXPONENT_BASE) * (1 + significand / 1024);
	}
	
	public function writeFLOAT16(value:Float):Void {
		HalfPrecisionWriter.write(value, this);
	}

	/////////////////////////////////////////////////////////
	// Encoded integer
	/////////////////////////////////////////////////////////
	
	public function readEncodedU32():Int {
		resetBitsPending();
		var result:Int = readUnsignedByte();
		if (result & 0x80 > 0) {
			result = (result & 0x7f) | (readUnsignedByte() << 7);
			if (result & 0x4000 > 0) {
				result = (result & 0x3fff) | (readUnsignedByte() << 14);
				if (result & 0x200000 > 0) {
					result = (result & 0x1fffff) | (readUnsignedByte() << 21);
					if (result & 0x10000000 > 0) {
						result = (result & 0xfffffff) | (readUnsignedByte() << 28);
					}
				}
			}
		}
		return result;
	}
	
	public function writeEncodedU32(value:Int):Void {
		//for (;;) {
			//var v:Int = value & 0x7f;
			//if ((value >>= 7) == 0) {
				//writeUI8(v);
				//break;
			//}
			//writeUI8(v | 0x80);
		//}
		//for (;;) {
			var v:Int = value & 0x7f;
			if ((value >>= 7) == 0) {
				writeUI8(v);
				return;
			}
			writeUI8(v | 0x80);
		//}
	}

	/////////////////////////////////////////////////////////
	// Bit values
	/////////////////////////////////////////////////////////
	
	public function readUB(bits:Int):Int {
		return readBits(bits);
	}

	public function writeUB(bits:Int, value:Int):Void {
		writeBits(bits, value);
	}

	public function readSB(bits:Int):Int {
		var shift:Int = 32 - bits;
		return Std.int(readBits(bits) << shift) >> shift;
	}
	
	public function writeSB(bits:Int, value:Int):Void {
		writeBits(bits, value);
	}
	
	public function readFB(bits:Int):Float {
		return readSB(bits) / 65536;
	}
	
	public function writeFB(bits:Int, value:Float):Void {
		writeSB(bits, Std.int (value * 65536));
	}
	
	/////////////////////////////////////////////////////////
	// String
	/////////////////////////////////////////////////////////
	
	public function readSTRING():String {
		var index:Int = position;
		while (this[index++] > 0) {}
		resetBitsPending();
		#if (neko || cpp) //TODO: Check for other targets that might require this
		var result = readUTFBytes(index - position - 1);
		position++;
		return result;
		#else
		return readUTFBytes(index - position);
		#end
	}
	
	public function writeSTRING(value:String):Void {
		if (value != null && value.length > 0) {
			writeUTFBytes(value);
		}
		writeByte(0);
	}
	
	/////////////////////////////////////////////////////////
	// Labguage code
	/////////////////////////////////////////////////////////
	
	public function readLANGCODE():Int {
		resetBitsPending();
		return readUnsignedByte();
	}
	
	public function writeLANGCODE(value:Int):Void {
		resetBitsPending();
		writeByte(value);
	}
	
	/////////////////////////////////////////////////////////
	// Color records
	/////////////////////////////////////////////////////////
	
	public function readRGB():Int {
		resetBitsPending();
		var r:Int = readUnsignedByte();
		var g:Int = readUnsignedByte();
		var b:Int = readUnsignedByte();
		return 0xff000000 | (r << 16) | (g << 8) | b;
	}
	
	public function writeRGB(value:Int):Void {
		resetBitsPending();
		writeByte((value >> 16) & 0xff);
		writeByte((value >> 8) & 0xff);
		writeByte(value  & 0xff);
	}

	public function readRGBA():Int {
		resetBitsPending();
		var rgb:Int = readRGB() & 0x00ffffff;
		var a:Int = readUnsignedByte();
		return a << 24 | rgb;
	}
	
	public function writeRGBA(value:Int):Void {
		resetBitsPending();
		writeRGB(value);
		writeByte((value >> 24) & 0xff);
	}

	public function readARGB():Int {
		resetBitsPending();
		var a:Int = readUnsignedByte();
		var rgb:Int = readRGB() & 0x00ffffff;
		return (a << 24) | rgb;
	}
	
	public function writeARGB(value:Int):Void {
		resetBitsPending();
		writeByte((value >> 24) & 0xff);
		writeRGB(value);
	}

	/////////////////////////////////////////////////////////
	// Rectangle record
	/////////////////////////////////////////////////////////
	
	public function readRECT():SWFRectangle {
		return new SWFRectangle(this);
	}
	
	public function writeRECT(value:SWFRectangle):Void {
		value.publish(this);
	}
	
	/////////////////////////////////////////////////////////
	// Matrix record
	/////////////////////////////////////////////////////////
	
	public function readMATRIX():SWFMatrix {
		return new SWFMatrix(this);
	}
	
	public function writeMATRIX(value:SWFMatrix):Void {
		this.resetBitsPending();

		var hasScale:Bool = (value.scaleX != 1) || (value.scaleY != 1);
		var hasRotate:Bool = (value.rotateSkew0 != 0) || (value.rotateSkew1 != 0);
		
		writeBits(1, hasScale ? 1 : 0);
		if (hasScale) {
			var scaleBits:Int;
			if(value.scaleX == 0 && value.scaleY == 0) {
				scaleBits = 1;
			} else {
				scaleBits = calculateMaxBits(true, [ Std.int (value.scaleX * 65536), Std.int (value.scaleY * 65536) ]);
			}
			writeUB(5, scaleBits);
			writeFB(scaleBits, value.scaleX);
			writeFB(scaleBits, value.scaleY);
		}
		
		writeBits(1, hasRotate ? 1 : 0);
		if (hasRotate) {
			var rotateBits:Int = calculateMaxBits(true, [ Std.int (value.rotateSkew0 * 65536), Std.int (value.rotateSkew1 * 65536) ]);
			writeUB(5, rotateBits);
			writeFB(rotateBits, value.rotateSkew0);
			writeFB(rotateBits, value.rotateSkew1);
		}
		
		var translateBits:Int = calculateMaxBits(true, [value.translateX, value.translateY]);
		writeUB(5, translateBits);
		writeSB(translateBits, value.translateX);
		writeSB(translateBits, value.translateY);
	}

	/////////////////////////////////////////////////////////
	// Color transform records
	/////////////////////////////////////////////////////////
	
	public function readCXFORM():SWFColorTransform {
		return new SWFColorTransform(this);
	}
	
	public function writeCXFORM(value:SWFColorTransform):Void {
		value.publish(this);
	}

	public function readCXFORMWITHALPHA():SWFColorTransformWithAlpha {
		return new SWFColorTransformWithAlpha(this);
	}
	
	public function writeCXFORMWITHALPHA(value:SWFColorTransformWithAlpha):Void {
		value.publish(this);
	}
	
	/////////////////////////////////////////////////////////
	// Shape and shape records
	/////////////////////////////////////////////////////////
	
	public function readSHAPE(unitDivisor:Float = 20):SWFShape {
		return new SWFShape(this, 1, unitDivisor);
	}
	
	public function writeSHAPE(value:SWFShape):Void {
		value.publish(this);
	}
	
	public function readSHAPEWITHSTYLE(level:Int = 1, unitDivisor:Float = 20):SWFShapeWithStyle {
		return new SWFShapeWithStyle(this, level, unitDivisor);
	}

	public function writeSHAPEWITHSTYLE(value:SWFShapeWithStyle, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readSTRAIGHTEDGERECORD(numBits:Int):SWFShapeRecordStraightEdge {
		return new SWFShapeRecordStraightEdge(this, numBits);
	}
	
	public function writeSTRAIGHTEDGERECORD(value:SWFShapeRecordStraightEdge):Void {
		value.publish(this);
	}
	
	public function readCURVEDEDGERECORD(numBits:Int):SWFShapeRecordCurvedEdge {
		return new SWFShapeRecordCurvedEdge(this, numBits);
	}
	
	public function writeCURVEDEDGERECORD(value:SWFShapeRecordCurvedEdge):Void {
		value.publish(this);
	}
	
	public function readSTYLECHANGERECORD(states:Int, fillBits:Int, lineBits:Int, level:Int = 1):SWFShapeRecordStyleChange {
		return new SWFShapeRecordStyleChange(this, states, fillBits, lineBits, level);
	}
	
	public function writeSTYLECHANGERECORD(value:SWFShapeRecordStyleChange, fillBits:Int, lineBits:Int, level:Int = 1):Void {
		value.numFillBits = fillBits;
		value.numLineBits = lineBits;
		value.publish(this, level);
	}
	

	/////////////////////////////////////////////////////////
	// Fill- and Linestyles
	/////////////////////////////////////////////////////////
	
	public function readFILLSTYLE(level:Int = 1):SWFFillStyle {
		return new SWFFillStyle(this, level);
	}
	
	public function writeFILLSTYLE(value:SWFFillStyle, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readLINESTYLE(level:Int = 1):SWFLineStyle {
		return new SWFLineStyle(this, level);
	}
	
	public function writeLINESTYLE(value:SWFLineStyle, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readLINESTYLE2(level:Int = 1):SWFLineStyle2 {
		return new SWFLineStyle2(this, level);
	}
	
	public function writeLINESTYLE2(value:SWFLineStyle2, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	/////////////////////////////////////////////////////////
	// Button record
	/////////////////////////////////////////////////////////
	
	public function readBUTTONRECORD(level:Int = 1):SWFButtonRecord {
		if (readUI8() == 0) {
			return null;
		} else {
			position--;
			return new SWFButtonRecord(this, level);
		}
	}

	public function writeBUTTONRECORD(value:SWFButtonRecord, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readBUTTONCONDACTION():SWFButtonCondAction {
		return new SWFButtonCondAction(this);
	}
	
	public function writeBUTTONCONDACTION(value:SWFButtonCondAction):Void {
		value.publish(this);
	}
	
	/////////////////////////////////////////////////////////
	// Filter
	/////////////////////////////////////////////////////////
	
	public function readFILTER():IFilter {
		var filterId:Int = readUI8();
		var filter:IFilter = SWFFilterFactory.create(filterId);
		filter.parse(this);
		return filter;
	}
	
	public function writeFILTER(value:IFilter):Void {
		writeUI8(value.id);
		value.publish(this);
	}
	
	/////////////////////////////////////////////////////////
	// Text record
	/////////////////////////////////////////////////////////
	
	public function readTEXTRECORD(glyphBits:Int, advanceBits:Int, previousRecord:SWFTextRecord = null, level:Int = 1):SWFTextRecord {
		if (readUI8() == 0) {
			return null;
		} else {
			position--;
			return new SWFTextRecord(this, glyphBits, advanceBits, previousRecord, level);
		}
	}
	
	public function writeTEXTRECORD(value:SWFTextRecord, glyphBits:Int, advanceBits:Int, previousRecord:SWFTextRecord = null, level:Int = 1):Void {
		value.publish(this, glyphBits, advanceBits, previousRecord, level);
	}

	public function readGLYPHENTRY(glyphBits:Int, advanceBits:Int):SWFGlyphEntry {
		return new SWFGlyphEntry(this, glyphBits, advanceBits);
	}

	public function writeGLYPHENTRY(value:SWFGlyphEntry, glyphBits:Int, advanceBits:Int):Void {
		value.publish(this, glyphBits, advanceBits);
	}
	
	/////////////////////////////////////////////////////////
	// Zone record
	/////////////////////////////////////////////////////////
	
	public function readZONERECORD():SWFZoneRecord {
		return new SWFZoneRecord(this);
	}

	public function writeZONERECORD(value:SWFZoneRecord):Void {
		value.publish(this);
	}
	
	public function readZONEDATA():SWFZoneData {
		return new SWFZoneData(this);
	}

	public function writeZONEDATA(value:SWFZoneData):Void {
		value.publish(this);
	}
	
	/////////////////////////////////////////////////////////
	// Kerning record
	/////////////////////////////////////////////////////////
	
	public function readKERNINGRECORD(wideCodes:Bool):SWFKerningRecord {
		return new SWFKerningRecord(this, wideCodes);
	}

	public function writeKERNINGRECORD(value:SWFKerningRecord, wideCodes:Bool):Void {
		value.publish(this, wideCodes);
	}
	
	/////////////////////////////////////////////////////////
	// Gradients
	/////////////////////////////////////////////////////////
	
	public function readGRADIENT(level:Int = 1):SWFGradient {
		return new SWFGradient(this, level);
	}
	
	public function writeGRADIENT(value:SWFGradient, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readFOCALGRADIENT(level:Int = 1):SWFFocalGradient {
		return new SWFFocalGradient(this, level);
	}
	
	public function writeFOCALGRADIENT(value:SWFFocalGradient, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readGRADIENTRECORD(level:Int = 1):SWFGradientRecord {
		return new SWFGradientRecord(this, level);
	}
	
	public function writeGRADIENTRECORD(value:SWFGradientRecord, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	/////////////////////////////////////////////////////////
	// Morphs
	/////////////////////////////////////////////////////////
	
	public function readMORPHFILLSTYLE(level:Int = 1):SWFMorphFillStyle {
		return new SWFMorphFillStyle(this, level);
	}
	
	public function writeMORPHFILLSTYLE(value:SWFMorphFillStyle, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readMORPHLINESTYLE(level:Int = 1):SWFMorphLineStyle {
		return new SWFMorphLineStyle(this, level);
	}
	
	public function writeMORPHLINESTYLE(value:SWFMorphLineStyle, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readMORPHLINESTYLE2(level:Int = 1):SWFMorphLineStyle2 {
		return new SWFMorphLineStyle2(this, level);
	}
	
	public function writeMORPHLINESTYLE2(value:SWFMorphLineStyle2, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readMORPHGRADIENT(level:Int = 1):SWFMorphGradient {
		return new SWFMorphGradient(this, level);
	}
	
	public function writeMORPHGRADIENT(value:SWFMorphGradient, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readMORPHFOCALGRADIENT(level:Int = 1):SWFMorphFocalGradient {
		return new SWFMorphFocalGradient(this, level);
	}
	
	public function writeMORPHFOCALGRADIENT(value:SWFMorphFocalGradient, level:Int = 1):Void {
		value.publish(this, level);
	}
	
	public function readMORPHGRADIENTRECORD():SWFMorphGradientRecord {
		return new SWFMorphGradientRecord(this);
	}
	
	public function writeMORPHGRADIENTRECORD(value:SWFMorphGradientRecord):Void {
		value.publish(this);
	}
	
	/////////////////////////////////////////////////////////
	// Action records
	/////////////////////////////////////////////////////////
	
	public function readACTIONRECORD():IAction {
		var pos:Int = position;
		var action:IAction = null;
		var actionCode:Int = readUI8();
		if (actionCode != 0) {
			var actionLength:Int = (actionCode >= 0x80) ? readUI16() : 0;
			action = SWFActionFactory.create(actionCode, actionLength, pos);
			action.parse(this);
		}
		return action;
	}
	
	public function writeACTIONRECORD(action:IAction):Void {
		action.publish(this);
	}
	
	/*public function readACTIONVALUE():SWFActionValue {
		return new SWFActionValue(this);
	}
	
	public function writeACTIONVALUE(value:SWFActionValue):Void {
		value.publish(this);
	}*/
	
	public function readREGISTERPARAM():SWFRegisterParam {
		return new SWFRegisterParam(this);
	}
	
	public function writeREGISTERPARAM(value:SWFRegisterParam):Void {
		value.publish(this);
	}
	
	/////////////////////////////////////////////////////////
	// Symbols
	/////////////////////////////////////////////////////////
	
	public function readSYMBOL():SWFSymbol {
		return new SWFSymbol(this);
	}
	
	public function writeSYMBOL(value:SWFSymbol):Void {
		value.publish(this);
	}
	
	/////////////////////////////////////////////////////////
	// Sound records
	/////////////////////////////////////////////////////////
	
	public function readSOUNDINFO():SWFSoundInfo {
		return new SWFSoundInfo(this);
	}
	
	public function writeSOUNDINFO(value:SWFSoundInfo):Void {
		value.publish(this);
	}
	
	public function readSOUNDENVELOPE():SWFSoundEnvelope {
		return new SWFSoundEnvelope(this);
	}
	
	public function writeSOUNDENVELOPE(value:SWFSoundEnvelope):Void {
		value.publish(this);
	}
	
	/////////////////////////////////////////////////////////
	// ClipEvents
	/////////////////////////////////////////////////////////
	
	public function readCLIPACTIONS(version:Int):SWFClipActions {
		return new SWFClipActions(this, version);
	}
	
	public function writeCLIPACTIONS(value:SWFClipActions, version:Int):Void {
		value.publish(this, version);
	}
	
	public function readCLIPACTIONRECORD(version:Int):SWFClipActionRecord {
		var pos:Int = position;
		var flags:Int = (version >= 6) ? readUI32() : readUI16();
		if (flags == 0) {
			return null;
		} else {
			position = pos;
			return new SWFClipActionRecord(this, version);
		}
	}
	
	public function writeCLIPACTIONRECORD(value:SWFClipActionRecord, version:Int):Void {
		value.publish(this, version);
	}
	
	public function readCLIPEVENTFLAGS(version:Int):SWFClipEventFlags {
		return new SWFClipEventFlags(this, version);
	}
	
	public function writeCLIPEVENTFLAGS(value:SWFClipEventFlags, version:Int):Void {
		value.publish(this, version);
	}
	
	
	/////////////////////////////////////////////////////////
	// Tag header
	/////////////////////////////////////////////////////////
	
	public function readTagHeader():SWFRecordHeader {
		var pos:Int = position;
		var tagTypeAndLength:Int = readUI16();
		var tagLength:Int = tagTypeAndLength & 0x003f;
		if (tagLength == 0x3f) {
			// The SWF10 spec sez that this is a signed int.
			// Shouldn't it be an unsigned int?
			tagLength = readSI32();
		}
		return new SWFRecordHeader(tagTypeAndLength >> 6, tagLength, position - pos);
	}

	public function writeTagHeader(type:Int, length:Int, forceLongHeader:Bool = false):Void {
		if (length < 0x3f && !forceLongHeader) {
			writeUI16((type << 6) | length);
		} else {
			writeUI16((type << 6) | 0x3f);
			// The SWF10 spec sez that this is a signed int.
			// Shouldn't it be an unsigned int?
			writeSI32(length);
		}
	}
	
	/////////////////////////////////////////////////////////
	// SWF Compression
	/////////////////////////////////////////////////////////
	
	public function swfUncompress(compressionMethod:CompressionAlgorithm, uncompressedLength:Int = 0):Void {
		var pos:Int = position;
		var ba:ByteArray = new ByteArray();
		
		if(compressionMethod == CompressionAlgorithm.ZLIB) {
			readBytes(ba);
			ba.position = 0;
			ba.uncompress();
		} else if(compressionMethod == CompressionAlgorithm.LZMA) {

			// LZMA compressed SWF:
			//   0000 5A 57 53 0F   (ZWS, Version 15)
			//   0004 DF 52 00 00   (Uncompressed size: 21215)
			//   0008 94 3B 00 00   (Compressed size: 15252)
			//   000C 5D 00 00 00 01   (LZMA Properties)
			//   0011 00 3B FF FC A6 14 16 5A ...   (15252 bytes of LZMA Compressed Data, until EOF)
			// 7z LZMA format:
			//   0000 5D 00 00 00 01   (LZMA Properties)
			//   0005 D7 52 00 00 00 00 00 00   (Uncompressed size: 21207, 64 bit)
			//   000D 00 3B FF FC A6 14 16 5A ...   (15252 bytes of LZMA Compressed Data, until EOF)
			// (see also https://github.com/claus/as3swf/pull/23#issuecomment-7203861)

			// Write LZMA properties
			for(i in 0...5) {
				ba.writeByte(this[i + 12]);
			}
			
			// Write uncompressed length (64 bit)
			ba.endian = Endian.LITTLE_ENDIAN;
			ba.writeUnsignedInt(uncompressedLength - 8);
			ba.writeUnsignedInt(0);
			
			// Write compressed data
			position = 17;
			readBytes(ba, 13);
			
			// Uncompress
			ba.position = 0;
			ba.uncompress(compressionMethod);
			
		} else {
			throw(new Error("Unknown compression method: " + compressionMethod));
		}
		
		length = position = pos;
		writeBytes(ba);
		position = pos;
	}
	
	public function swfCompress(compressionMethod:CompressionAlgorithm):Void {
		var pos:Int = position;
		var ba:ByteArray = new ByteArray();
		
		if(compressionMethod == CompressionAlgorithm.ZLIB) {
			readBytes(ba);
			ba.position = 0;
			ba.compress();
		} else if(compressionMethod == CompressionAlgorithm.LZMA) {
			// Never should get here (unfortunately)
			// We're forcing ZLIB compression on publish, see CSS.as line 145
			throw(new Error("Can't publish LZMA compressed SWFs"));
			// This should be correct, but doesn't seem to work:
			var lzma:ByteArray = new ByteArray();
			readBytes(lzma);
			lzma.position = 0;
			lzma.compress(compressionMethod);
			// Write compressed length
			ba.endian = Endian.LITTLE_ENDIAN;
			ba.writeUnsignedInt(lzma.length - 13);
			// Write LZMA properties
			for(i in 0...5) {
				ba.writeByte(lzma[i]);
			}
			// Write compressed data
			ba.writeBytes(lzma, 13);
		} else {
			throw(new Error("Unknown compression method: " + compressionMethod));
		}
		
		length = position = pos;
		writeBytes(ba);
	}
	
	/////////////////////////////////////////////////////////
	// etc
	/////////////////////////////////////////////////////////
	
	public function readRawTag():SWFRawTag {
		return new SWFRawTag(this);
	}
	
	public function skipBytes(length:Int):Void {
		position += length;
	}
	
	public static function dump(ba:ByteArray, length:Int, offset:Int = 0):Void {
		var posOrig:Int = ba.position;
		var pos:Int = ba.position = Std.int (Math.min(Math.max(posOrig + offset, 0), ba.length - length));
		var str:String = "[Dump] total length: " + ba.length + ", original position: " + posOrig;
		for (i in 0...length) {
			var b:String = StringTools.hex (ba.readUnsignedByte());
			if(b.length == 1) { b = "0" + b; }
			if(i % 16 == 0) {
				var addr:String = StringTools.hex ((pos + i));
				addr = "00000000".substr(0, 8 - addr.length) + addr;
				str += "\r" + addr + ": ";
			}
			b += " ";
			str += b;
		}
		ba.position = posOrig;
		trace(str);
	}
}