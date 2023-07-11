package swf.utils;

class SymbolUtils
{
	public static function formatClassName(className:String, prefix:String = null):String
	{
		if (className == null) return null;
		if (prefix == null) prefix = "";

		var lastIndexOfPeriod = className.lastIndexOf(".");

		var packageName = "";
		var name = "";

		if (lastIndexOfPeriod == -1)
		{
			name = prefix + className;
		}
		else
		{
			packageName = className.substr(0, lastIndexOfPeriod);
			name = prefix + className.substr(lastIndexOfPeriod + 1);
		}

		packageName = packageName.charAt(0).toLowerCase() + packageName.substr(1);
		name = name.substr(0, 1).toUpperCase() + name.substr(1);

		if (packageName != "")
		{
			return StringTools.trim(packageName + "." + name);
		}
		else
		{
			return StringTools.trim(name);
		}
	}
}
