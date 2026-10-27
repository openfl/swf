package tests;

// Matches a class generated from templates/animate/MovieClip.mtt with the prefix "Lib",
// for a symbol linked as tests.PrefixedTestClip
@:access(swf.exporters.animate)
class LibPrefixedTestClip extends openfl.display.MovieClip
{
	public static inline var UUID = "generated-prefix-test";

	@:noCompletion private static function __init__():Void
	{
		swf.exporters.animate.AnimateLibrary.__registerGeneratedClass(UUID, 1, LibPrefixedTestClip);
	}

	public function new()
	{
		if (!swf.exporters.animate.AnimateSymbol.__initPending(LibPrefixedTestClip))
		{
			var library = swf.exporters.animate.AnimateLibrary.get(UUID);
			var symbol = library.symbols.get(1);
			symbol.__init(library);
		}

		super();
	}
}
