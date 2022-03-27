package swf.exporters.animate;

import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Shape;
import openfl.geom.Matrix;
import swf.utils.ColorUtils;

@:access(swf.exporters.animate.AnimateLibrary)
@:access(openfl.display.CapsStyle)
@:access(openfl.display.GradientType)
@:access(openfl.display.InterpolationMethod)
@:access(openfl.display.JointStyle)
@:access(openfl.display.LineScaleMode)
@:access(openfl.display.SpreadMethod)
class AnimateMorphShape extends openfl.display.Shape
{
	public var ratio(default, null): Int;

    private var symbol: AnimateMorphShapeSymbol;
    private var library: AnimateLibrary;

    private var __colors: Array<Int> = [];
    private var __alphas: Array<Float> = [];
    private var __ratios: Array<Int> = [];
    private var __matrix = new Matrix();

	public function new(symbol: AnimateMorphShapeSymbol, library: AnimateLibrary, ratio: Int = 0)
	{
		super();

        this.symbol = symbol;
        this.library = library;
        this.ratio = ratio;

        render(this.ratio);
	}

	public function render(ratio:Int = 0)
	{
        this.ratio = ratio;
		graphics.clear();

        if (symbol.rendered.exists(ratio)) {
            graphics.copyFrom(symbol.rendered[ratio].graphics);
            return;
        }

        var a = ratio / 65535.0;
        var b = 1.0 - ratio;

		for (command in symbol.commands)
		{
			switch (command)
			{
				case BeginFill(startColor, endColor, startAlpha, endAlpha):
					graphics.beginFill(ColorUtils.interpolate(startColor, endColor, a), lerpf(startAlpha, endAlpha, a, b));

				case BeginBitmapFill(bitmapID, startMatrix, endMatrix, repeat, smooth):
					#if lime
					var bitmapSymbol:AnimateBitmapSymbol = cast library.symbols.get(bitmapID);
					var bitmap = library.getImage(bitmapSymbol.path);

					if (bitmap != null)
					{
						graphics.beginBitmapFill(BitmapData.fromImage(bitmap),
                                                 lerpMatrix(startMatrix, endMatrix, a, b),
                                                 repeat, smooth);
					}
					#end

				case BeginGradientFill(fillType, startColors, endColors, startAlphas, endAlphas, startRatios, endRatios, startMatrix, endMatrix,
                                       spreadMethod, interpolationMethod, focalPointRatio):
					// #if flash
					// var colors:Array<UInt> = cast colors;
					// #end

					graphics.beginGradientFill(GradientType.fromInt(fillType),
                                               lerpColors(startColors, endColors, a, b),
                                               lerpAlphas(startAlphas, endAlphas, a, b),
                                               lerpRatios(startRatios, endRatios, a, b),
                                               lerpMatrix(startMatrix, endMatrix, a, b),
                                               SpreadMethod.fromInt(spreadMethod),
                                               InterpolationMethod.fromInt(interpolationMethod),
                                               focalPointRatio);

				case CurveTo(startControlX, startControlY, startAnchorX, startAnchorY, endControlX, endControlY, endAnchorX, endAnchorY):
					graphics.curveTo(lerpf(startControlX, endControlX, a, b),
                                     lerpf(startControlY, endControlY, a, b),
                                     lerpf(startAnchorX, endAnchorX, a, b),
                                     lerpf(startAnchorY, endAnchorY, a, b));

				case EndFill:
					graphics.endFill();

				case LineStyle(startThickness, endThickness, startColor, endColor, startAlpha, endAlpha, pixelHinting, scaleMode, caps, joints, miterLimit):
					if (startThickness != null)
					{
						graphics.lineStyle(lerpf(startThickness, endThickness, a, b),
                                           ColorUtils.interpolate(startColor, endColor, a),
                                           lerpf(startAlpha, endAlpha, a, b),
                                           pixelHinting,
                                           LineScaleMode.fromInt(scaleMode),
                                           CapsStyle.fromInt(caps),
                                           JointStyle.fromInt(joints),
                                           miterLimit);
					}
					else
					{
						graphics.lineStyle();
					}

				case LineTo(startX, startY, endX, endY):
					graphics.lineTo(lerpf(startX, startY, a, b), lerpf(endX, endY, a, b));

				case MoveTo(startX, startY, endX, endY):
					graphics.moveTo(lerpf(startX, startY, a, b), lerpf(endX, endY, a, b));
			}
		}

		var rendered = new Shape();
		rendered.graphics.copyFrom(graphics);
        symbol.rendered[ratio] = rendered;
	}

    private inline function lerpf(start:Float, end:Float, a:Float, b:Float): Float {
        return start * a + end * b;
    }

    private inline function lerpColors(start:Array<Int>, end:Array<Int>, a:Float, b:Float): Array<Int> {
        __colors.resize(start.length);
        for (i in 0...start.length) {
            __colors[i] = ColorUtils.interpolate(start[i], end[i], a);
        }
        return __colors;
    }

    private inline function lerpAlphas(start:Array<Float>, end:Array<Float>, a:Float, b:Float): Array<Float> {
        __alphas.resize(start.length);
        for (i in 0...start.length) {
            __alphas[i] = lerpf(start[i], end[i], a, b);
        }
        return __alphas;
    }

    private inline function lerpRatios(start:Array<Int>, end:Array<Int>, a:Float, b:Float): Array<Int> {
        __ratios.resize(start.length);
        for (i in 0...start.length) {
            __ratios[i] = Std.int(lerpf(start[i], end[i], a, b));
        }
        return __ratios;
    }

    private inline function lerpMatrix(matrix1:Matrix, matrix2:Matrix, a:Float, b:Float): Matrix {
		__matrix.a = matrix1.a * a + matrix2.a * b;
		__matrix.b = matrix1.b * a + matrix2.b * b;
		__matrix.c = matrix1.c * a + matrix2.c * b;
		__matrix.d = matrix1.d * a + matrix2.d * b;
		__matrix.tx = Std.int(matrix1.tx * a + matrix2.tx * b);
		__matrix.ty = Std.int(matrix1.ty * a + matrix2.ty * b);
        return __matrix;
    }
}
