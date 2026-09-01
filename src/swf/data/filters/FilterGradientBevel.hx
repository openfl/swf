package swf.data.filters;

import swf.utils.ColorUtils;
import swf.exporters.core.FilterType;
import openfl.filters.BitmapFilter;
import openfl.filters.GradientBevelFilter;
import openfl.filters.BitmapFilterType;

class FilterGradientBevel extends FilterGradientGlow implements IFilter
{
	public function new(id:Int)
	{
		super(id);
	}

	override private function get_filter():BitmapFilter
	{
		#if ((cpp || neko) && openfl_legacy)
		return new BitmapFilter("");
		#else
		var gradientBevelColors:Array<Int> = [];
		var gradientBevelAlphas:Array<Float> = [];
		var gradientBevelRatios:Array<Int> = [];
		for (i in 0...numColors)
		{
			gradientBevelColors.push(ColorUtils.rgb(gradientColors[i]));
			gradientBevelAlphas.push(ColorUtils.alpha(gradientColors[i]));
			gradientBevelRatios.push(gradientRatios[i]);
		}
		var filterType = getBitmapFilterType();
		return new GradientBevelFilter(distance, angle * 180 / Math.PI, gradientBevelColors, gradientBevelAlphas, gradientBevelRatios, blurX, blurY, strength, passes, filterType, knockout);
		#end
	}

	override private function get_type():FilterType
	{
		var colors:Array<Int> = [];
		var alphas:Array<Float> = [];
		var ratios:Array<Int> = [];
		for (i in 0...numColors)
		{
			colors.push(ColorUtils.rgb(gradientColors[i]));
			alphas.push(ColorUtils.alpha(gradientColors[i]));
			ratios.push(gradientRatios[i]);
		}
		var filterType = getBitmapFilterType();
		return GradientBevelFilter(distance, angle * 180 / Math.PI, colors, alphas, ratios, blurX, blurY, strength, passes, filterType, knockout);
	}

	override public function clone():IFilter
	{
		var filter:FilterGradientBevel = new FilterGradientBevel(id);
		filter.numColors = numColors;
		var i:Int;
		for (i in 0...numColors)
		{
			filter.gradientColors.push(gradientColors[i]);
		}
		for (i in 0...numColors)
		{
			filter.gradientRatios.push(gradientRatios[i]);
		}
		filter.blurX = blurX;
		filter.blurY = blurY;
		filter.angle = angle;
		filter.distance = distance;
		filter.strength = strength;
		filter.passes = passes;
		filter.inner = inner;
		filter.knockout = knockout;
		filter.compositeSource = compositeSource;
		filter.onTop = onTop;
		return filter;
	}

	override private function get_filterName():String
	{
		return "GradientBevelFilter";
	}
}
