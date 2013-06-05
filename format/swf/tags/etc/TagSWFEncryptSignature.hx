package format.swf.tags.etc;

import format.swf.tags.ITag;
import format.swf.tags.TagUnknown;

class TagSWFEncryptSignature extends TagUnknown #if !haxe3 , #end implements ITag
{
	public static inline var TYPE:Int = 255;
	
	public function TagSWFEncryptSignature(type:Int = 0) {
		
		this.type = TYPE;
		name = "SWFEncryptSignature";
		
	}
	
}