package tests;

import openfl.utils.ByteArray;
import swf.SWF;
import swf.SWFData;
import swf.SWFRoot;
import swf.data.SWFSymbol;
import swf.tags.ITag;
import swf.tags.TagDefineSprite;
import swf.tags.TagEnd;
import swf.tags.TagShowFrame;
import swf.tags.TagSymbolClass;

// Writes a minimal uncompressed SWF file from tags created in code
class SWFBuilder
{
	private var symbolClass:TagSymbolClass;
	private var tags:Array<ITag>;

	public function new()
	{
		tags = [];
		symbolClass = new TagSymbolClass();
	}

	public function add(tag:ITag):SWFBuilder
	{
		tags.push(tag);
		return this;
	}

	public function link(characterId:Int, className:String):SWFBuilder
	{
		symbolClass.symbols.push(SWFSymbol.create(characterId, className));
		return this;
	}

	public function build():ByteArray
	{
		var output = new SWFData();
		output.writeUI8(0x46);
		output.writeUI8(0x57);
		output.writeUI8(0x53);
		output.writeUI8(10);
		output.writeUI32(0);
		// RECT with 12 bit values, for a 100x100 stage
		for (value in [0x60, 0x00, 0x3E, 0x80, 0x00, 0x3E, 0x80])
		{
			output.writeUI8(value);
		}
		output.writeUI8(0x00);
		output.writeUI8(0x18);
		output.writeUI16(1);

		for (tag in tags)
		{
			tag.publish(output, 10);
		}
		if (symbolClass.symbols.length > 0)
		{
			symbolClass.publish(output, 10);
		}
		new TagShowFrame().publish(output, 10);
		new TagEnd().publish(output, 10);

		var length = output.length;
		output.position = 4;
		output.writeUI32(length);
		output.position = 0;
		return output;
	}

	public function parse():SWFRoot
	{
		return new SWF(build()).data;
	}

	public static function createSprite(characterId:Int):TagDefineSprite
	{
		var sprite = new TagDefineSprite();
		sprite.characterId = characterId;
		sprite.frameCount = 1;
		sprite.tags.push(new TagShowFrame());
		sprite.tags.push(new TagEnd());
		return sprite;
	}
}
