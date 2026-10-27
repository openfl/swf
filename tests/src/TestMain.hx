import openfl.display.Sprite;
import utest.Runner;
import utest.ui.Report;

class TestMain extends Sprite
{
	public function new()
	{
		super();

		var runner = new Runner();
		#if !flash
		runner.addCase(new tests.AnimateBitmapSymbolTest());
		#end
		runner.addCase(new tests.AnimateGeneratedClassTest());
		runner.addCase(new tests.AnimateLibraryTest());
		runner.addCase(new tests.AnimateShapeSymbolTest());
		runner.addCase(new tests.AnimateTimelineTest());
		#if !flash
		runner.addCase(new tests.DynamicTextFontTest());
		#end
		runner.addCase(new tests.ShapeExportTest());
		runner.addCase(new tests.ShapesTest());
		#if !flash
		runner.addCase(new tests.SWFLiteExporterTest());
		#end
		runner.addCase(new tests.TagDefineFont2Test());
		runner.addCase(new tests.TimelineTest());

		Report.create(runner);

		runner.run();
	}
}
