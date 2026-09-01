package swf.data.filters;

import swf.SWFData;
import swf.utils.ColorUtils;
import swf.utils.StringUtils;
import swf.exporters.core.FilterType;
import openfl.filters.BitmapFilter;
import openfl.filters.GradientGlowFilter;
import openfl.filters.BitmapFilterType;

class FilterGradientGlow extends Filter implements IFilter
{
	public var numColors:Int;
	public var blurX:Float;
	public var blurY:Float;
	public var angle:Float;
	public var distance:Float;
	public var strength:Float;
	public var inner:Bool;
	public var knockout:Bool;
	public var compositeSource:Bool;
	public var onTop:Bool;
	public var passes:Int;
	public var gradientColors(default, null):Array<Int>;
	public var gradientRatios(default, null):Array<Int>;
	public var filterName(get, null):String;

	public function new(id:Int)
	{
		super(id);
		gradientColors = new Array<Int>();
		gradientRatios = new Array<Int>();
	}

	override private function get_filter():BitmapFilter
	{
		#if ((cpp || neko) && openfl_legacy)
		return new BitmapFilter("");
		#else
		var gradientGlowColors:Array<Int> = [];
		var gradientGlowAlphas:Array<Float> = [];
		var gradientGlowRatios:Array<Int> = [];
		for (i in 0...numColors)
		{
			gradientGlowColors.push(ColorUtils.rgb(gradientColors[i]));
			gradientGlowAlphas.push(ColorUtils.alpha(gradientColors[i]));
			gradientGlowRatios.push(gradientRatios[i]);
		}
		var filterType = getBitmapFilterType();
		return new GradientGlowFilter(distance, angle * 180 / Math.PI, gradientGlowColors, gradientGlowAlphas, gradientGlowRatios, blurX, blurY, strength, passes, filterType, knockout);
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
		return GradientGlowFilter(distance, angle * 180 / Math.PI, colors, alphas, ratios, blurX, blurY, strength, passes, filterType, knockout);
	}

	override public function parse(data:SWFData):Void
	{
		numColors = data.readUI8();
		var i:Int;
		for (i in 0...numColors)
		{
			gradientColors.push(data.readRGBA());
		}
		for (i in 0...numColors)
		{
			gradientRatios.push(data.readUI8());
		}
		blurX = data.readFIXED();
		blurY = data.readFIXED();
		angle = data.readFIXED();
		distance = data.readFIXED();
		strength = data.readFIXED8();
		var flags:Int = data.readUI8();
		inner = ((flags & 0x80) != 0);
		knockout = ((flags & 0x40) != 0);
		compositeSource = ((flags & 0x20) != 0);
		onTop = ((flags & 0x10) != 0);
		passes = flags & 0x0f;
	}

	override public function publish(data:SWFData):Void
	{
		data.writeUI8(numColors);
		var i:Int;
		for (i in 0...numColors)
		{
			data.writeRGBA(gradientColors[i]);
		}
		for (i in 0...numColors)
		{
			data.writeUI8(gradientRatios[i]);
		}
		data.writeFIXED(blurX);
		data.writeFIXED(blurY);
		data.writeFIXED(angle);
		data.writeFIXED(distance);
		data.writeFIXED8(strength);
		var flags:Int = (passes & 0x0f);
		if (inner)
		{
			flags |= 0x80;
		}
		if (knockout)
		{
			flags |= 0x40;
		}
		if (compositeSource)
		{
			flags |= 0x20;
		}
		if (onTop)
		{
			flags |= 0x10;
		}
		data.writeUI8(flags);
	}

	override public function clone():IFilter
	{
		var filter:FilterGradientGlow = new FilterGradientGlow(id);
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

	private  function getBitmapFilterType()
	{
		return onTop ? BitmapFilterType.FULL : (inner ? BitmapFilterType.INNER : BitmapFilterType.OUTER);
	}

	override public function toString(indent:Int = 0):String
	{
		var i:Int;
		var str:String = "[" + filterName + "] " + "BlurX: " + blurX + ", " + "BlurY: " + blurY + ", " + "Angle: " + angle + ", " + "Distance: " + distance
			+ ", " + "Strength: " + strength + ", " + "Passes: " + passes;
		var flags:Array<String> = [];
		if (inner)
		{
			flags.push("InnerShadow");
		}
		if (knockout)
		{
			flags.push("Knockout");
		}
		if (compositeSource)
		{
			flags.push("CompositeSource");
		}
		if (onTop)
		{
			flags.push("OnTop");
		}
		if (flags.length > 0)
		{
			str += ", Flags: " + flags.join(", ");
		}
		if (gradientColors.length > 0)
		{
			str += "\n" + StringUtils.repeat(indent + 2) + "GradientColors:";
			for (i in 0...gradientColors.length)
			{
				str += ((i > 0) ? ", " : " ") + ColorUtils.rgbToString(gradientColors[i]);
			}
		}
		if (gradientRatios.length > 0)
		{
			str += "\n" + StringUtils.repeat(indent + 2) + "GradientRatios:";
			for (i in 0...gradientRatios.length)
			{
				str += ((i > 0) ? ", " : " ") + gradientRatios[i];
			}
		}
		return str;
	}

	private function get_filterName():String
	{
		return "GradientGlowFilter";
	}
}
