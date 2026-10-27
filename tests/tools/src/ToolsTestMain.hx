// Tests for the command-line tools, which need sys and hxp, so they are separate from the OpenFL tests
class ToolsTestMain
{
	public static function main():Void
	{
		utest.UTest.run([new tools.AnimateLibraryExporterTest(), new tools.ToolsTest()]);
	}
}
