package swf.factories;

// import swf.data.filters.*;
import swf.data.filters.IFilter;
import swf.data.filters.FilterDropShadow;
import swf.data.filters.FilterBlur;
import swf.data.filters.FilterGlow;
import swf.data.filters.FilterBevel;
import swf.data.filters.FilterGradientBevel;
import swf.data.filters.FilterGradientGlow;
import swf.data.filters.FilterConvolution;
import swf.data.filters.FilterColorMatrix;
import openfl.errors.Error;

class SWFFilterFactory
{
	public static function create(id:Int):IFilter
	{
		switch (id)
		{
			case 0:
				return new FilterDropShadow(id);
			case 1:
				return new FilterBlur(id);
			case 2:
				return new FilterGlow(id);
			case 3:
				return new FilterBevel(id);
			case 4:
				return new FilterGradientGlow(id);
			case 5:
				return new FilterConvolution(id);
			case 6:
				return new FilterColorMatrix(id);
			case 7:
				return new FilterGradientBevel(id);
			default:
				throw(new Error("Unknown filter ID: " + id));
		}
	}
}
