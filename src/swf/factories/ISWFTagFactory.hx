package swf.factories;

import swf.tags.ITag;

interface ISWFTagFactory
{
	function create(type:Int):ITag;
}
