package swf.tags.etc;

import swf.tags.ITag;
import swf.tags.TagUnknown;

class TagSWFEncryptSignature extends TagUnknown implements ITag
{
	public static inline var TYPE:Int = 255;

	public function TagSWFEncryptSignature(type:Int = 0)
	{
		this.type = TYPE;
		name = "SWFEncryptSignature";
	}
}
