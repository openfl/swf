import openfl.display.Sprite;
import utest.Runner;
import utest.ui.Report;

class TestMain extends Sprite
{
	public function new()
	{
		super();

		var runner = new Runner();
		runner.addCase(new tests.ShapesTest());

		Report.create(runner);

		runner.run();
	}
}
