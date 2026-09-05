package swf.exporters.core;

enum FilterType
{
	BlurFilter(blurX:Float, blurY:Float, quality:Int);
	ColorMatrixFilter(matrix:Array<Float>);
	DropShadowFilter(distance:Float, angle:Float, color:Int, alpha:Float, blurX:Float, blurY:Float, strength:Float, quality:Int, inner:Bool, knockout:Bool,
		hideObject:Bool);
	GlowFilter(color:Int, alpha:Float, blurX:Float, blurY:Float, strength:Float, quality:Int, inner:Bool, knockout:Bool);
	GradientGlowFilter(distance:Float, angle:Float, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, blurX:Float, blurY:Float, strength:Float,
		quality:Int, type:String, knockout:Bool);
	GradientBevelFilter(distance:Float, angle:Float, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, blurX:Float, blurY:Float, strength:Float,
		quality:Int, type:String, knockout:Bool);
}
