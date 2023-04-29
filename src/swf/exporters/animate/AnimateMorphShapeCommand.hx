package swf.exporters.animate;

import openfl.geom.Matrix;

enum AnimateMorphShapeCommand
{
	BeginBitmapFill(bitmap:Int,
                    startMatrix:Matrix, endMatrix: Matrix,
                    repeat:Bool,
                    smooth:Bool);
	BeginFill(startColor:Int, endColor:Int,
              startAlpha:Float, endAlpha:Float);
	BeginGradientFill(fillType:Null<Int> /*GradientType*/,
                      beginColors:Array<Int>, endColors:Array<Int>,
                      beginAlphas:Array<Float>, endAlphas:Array<Float>,
                      beginRatios:Array<Int>, endRatios:Array<Int>,
                      beginMatrix:Matrix, endMatrix:Matrix,
                      spreadMethod:Null<Int> /*SpreadMethod*/,
                      interpolationMethod:Null<Int> /*InterpolationMethod*/,
                      focalPointRatio:Float);
	// CubicCurveTo (controlX1:Float, controlY1:Float, controlX2:Float, controlY2:Float, anchorX:Float, anchorY:Float);
	CurveTo(beginControlX:Float, beginControlY:Float,
            beginAnchorX:Float, beginAnchorY:Float,
            endControlX:Float, endControlY:Float,
            endAnchorX:Float, endAnchorY:Float);
	// DrawCircle (x:Float, y:Float, radius:Float);
	// DrawEllipse (x:Float, y:Float, width:Float, height:Float);
	// DrawRect (x:Float, y:Float, width:Float, height:Float);
	// DrawRoundRect (x:Float, y:Float, width:Float, height:Float, rx:Float, ry:Float);
	// DrawTiles (sheet:Tilesheet, tileData:Array<Float>, smooth:Bool, flags:Int, count:Int);
	// DrawTriangles (vertices:Vector<Float>, indices:Vector<Int>, uvtData:Vector<Float>, culling:TriangleCulling);
	EndFill;
	LineStyle(beginThickness:Null<Float>, endThickness:Null<Float>,
              beginColor:Null<Int>, endColor:Null<Int>,
              beginAlpha:Null<Float>, endAlpha:Null<Float>,
              pixelHinting:Null<Bool>,
              scaleMode:Null<Int> /*LineScaleMode*/,
              caps:Null<Int> /*CapsStyle*/,
              joints:Null<Int> /*JointStyle*/,
              miterLimit:Null<Float>);
	LineTo(beginX:Float, beginY:Float, endX:Float, endY:Float);
	MoveTo(beginX:Float, beginY:Float, endX:Float, endY:Float);
}
