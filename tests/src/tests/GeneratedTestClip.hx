package tests;

// Matches the class generated from templates/animate/MovieClip.mtt
@:access(swf.exporters.animate)
class GeneratedTestClip extends openfl.display.MovieClip
{
	public static inline var UUID = "generated-class-test-a";

	public function new()
	{
		if (!swf.exporters.animate.AnimateSymbol.__initPending(GeneratedTestClip))
		{
			var library = swf.exporters.animate.AnimateLibrary.get(UUID);
			var symbol = library.symbols.get(1);
			symbol.__init(library);
		}

		super();
	}
}
