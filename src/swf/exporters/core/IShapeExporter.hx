package swf.exporters.core;

import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.GradientType;
import openfl.display.InterpolationMethod;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.SpreadMethod;
import openfl.geom.Matrix;

interface IShapeExporter
{
	function beginShape():Void;
	function endShape():Void;
	function beginFills():Void;
	function endFills():Void;
	function beginLines():Void;
	function endLines():Void;
	function beginFill(color:Int, alpha:Float = 1.0):Void;
	function beginGradientFill(type:GradientType, colors:Array<UInt>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix = null,
		spreadMethod:SpreadMethod = PAD, interpolationMethod:InterpolationMethod = RGB, focalPointRatio:Float = 0):Void;
	function beginBitmapFill(bitmapId:Int, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false):Void;
	function endFill():Void;
	function lineStyle(thickness:Null<Float> = null, color:Int = 0, alpha:Float = 1.0, pixelHinting:Bool = false, scaleMode:LineScaleMode = NORMAL,
		startCaps:CapsStyle = null, endCaps:CapsStyle = null, joints:JointStyle = null, miterLimit:Float = 3):Void;
	function lineGradientStyle(type:GradientType, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix = null,
		spreadMethod:SpreadMethod = PAD, interpolationMethod:InterpolationMethod = RGB, focalPointRatio:Float = 0):Void;
	function moveTo(x:Float, y:Float):Void;
	function lineTo(x:Float, y:Float):Void;
	function curveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float):Void;
}
