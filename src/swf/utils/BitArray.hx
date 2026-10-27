package swf.utils;

import openfl.utils.ByteArray;

class BitArray extends ByteArrayData
{
	private var bitsPending:Int = 0;

	public function readBits(bits:Int, bitBuffer:Int = 0):Int
	{
		if (bits == 0)
		{
			return bitBuffer;
		}
		var partial:Int;
		var bitsConsumed:Int;
		if (bitsPending > 0)
		{
			var byte:Int = this.get(position - 1) & (0xff >> (8 - bitsPending));
			bitsConsumed = Std.int(Math.min(bitsPending, bits));
			bitsPending -= bitsConsumed;
			partial = byte >> bitsPending;
		}
		else
		{
			bitsConsumed = Std.int(Math.min(8, bits));
			bitsPending = 8 - bitsConsumed;
			partial = readUnsignedByte() >> bitsPending;
		}
		bits -= bitsConsumed;
		bitBuffer = (bitBuffer << bitsConsumed) | partial;
		return (bits > 0) ? readBits(bits, bitBuffer) : bitBuffer;
	}

	public function writeBits(bits:Int, value:Int):Void
	{
		if (bits == 0)
		{
			return;
		}
		value &= (0xffffffff >>> (32 - bits));
		var bitsConsumed:Int;
		if (bitsPending > 0)
		{
			#if cpp
			if (bitsPending > bits)
			{
				position--;
				var setValue = readInt();
				setValue |= value << (bitsPending - bits);
				position--;
				writeInt(setValue);
				bitsConsumed = bits;
				bitsPending -= bits;
			}
			else if (bitsPending == bits)
			{
				position--;
				var setValue = readInt();
				setValue |= value;
				position--;
				writeInt(setValue);
				bitsConsumed = bits;
				bitsPending = 0;
			}
			else
			{
				position--;
				var setValue = readInt();
				setValue |= value >> (bits - bitsPending);
				position--;
				writeInt(setValue);
				bitsConsumed = bitsPending;
				bitsPending = 0;
			}
			#else
			if (bitsPending > bits)
			{
				this.set(position - 1, this.get(position - 1) | value << (bitsPending - bits));
				bitsConsumed = bits;
				bitsPending -= bits;
			}
			else if (bitsPending == bits)
			{
				this.set(position - 1, this.get(position - 1) | value);
				bitsConsumed = bits;
				bitsPending = 0;
			}
			else
			{
				this.set(position - 1, this.get(position - 1) | value >> (bits - bitsPending));
				bitsConsumed = bitsPending;
				bitsPending = 0;
			}
			#end
		}
		else
		{
			bitsConsumed = Std.int(Math.min(8, bits));
			bitsPending = 8 - bitsConsumed;
			writeByte((value >> (bits - bitsConsumed)) << bitsPending);
		}
		bits -= bitsConsumed;
		if (bits > 0)
		{
			writeBits(bits, value);
		}
	}

	public function resetBitsPending():Void
	{
		bitsPending = 0;
	}

	public function calculateMaxBits(signed:Bool, values:Array<Int>):Int
	{
		var bits:Int = 0;
		for (value in values)
		{
			if (value == 0)
			{
				continue;
			}
			// A signed value needs the bits of its magnitude plus a sign bit
			var magnitude:Int = (signed && value < 0) ? ~value : value;
			var valueBits:Int = signed ? 1 : 0;
			while (magnitude != 0)
			{
				magnitude >>>= 1;
				valueBits++;
			}
			if (valueBits > bits)
			{
				bits = valueBits;
			}
		}
		return bits;
	}

	#if flash
	private function get(pos:UInt):UInt
	{
		return this[pos];
	}

	private function set(pos:UInt, value:UInt):UInt
	{
		return this[pos] = value;
	}
	#end
}
