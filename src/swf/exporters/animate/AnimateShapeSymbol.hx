package swf.exporters.animate;

import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.GradientType;
import openfl.display.InterpolationMethod;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Shape;
import openfl.display.SpreadMethod;
#if (lime && !flash && swf_hardware_bitmap_cache)
import openfl.display._internal.Context3DGraphics;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(swf.exporters.animate.AnimateLibrary)
@:access(openfl.display.CapsStyle)
@:access(openfl.display.GradientType)
@:access(openfl.display.InterpolationMethod)
@:access(openfl.display.JointStyle)
@:access(openfl.display.LineScaleMode)
@:access(openfl.display.SpreadMethod)
#if (lime && !flash && swf_hardware_bitmap_cache)
@:access(openfl.display._internal.Context3DGraphics)
#end
class AnimateShapeSymbol extends AnimateSymbol
{
	public var commands:Array<AnimateShapeCommand>;
	public var rendered:Shape;

	#if (lime && !flash && swf_hardware_bitmap_cache)
	private static var __probeBitmapData:BitmapData;
	private var hardwareCompatible:Null<Bool>;
	private var requiresReadableBitmapData:Bool;
	#end

	public function new()
	{
		super();
	}

	private override function __createObject(library:AnimateLibrary):Shape
	{
		var shape = new Shape();
		var graphics = shape.graphics;

		if (rendered != null)
		{
			graphics.copyFrom(rendered.graphics);
			return shape;
		}

		var hardwareBitmapFills = false;
		#if (lime && !flash && swf_hardware_bitmap_cache)
		__prepareBitmapCache(library);
		hardwareBitmapFills = !requiresReadableBitmapData && hardwareCompatible == true;
		#end

		__renderCommands(graphics, library, hardwareBitmapFills, false);

		commands = null;
		rendered = new Shape();
		rendered.graphics.copyFrom(shape.graphics);

		return shape;
	}

	#if (lime && !flash && swf_hardware_bitmap_cache)
	@:allow(swf.exporters.animate.AnimateLibrary)
	private function __prepareBitmapCache(library:AnimateLibrary):Void
	{
		if (hardwareCompatible == null)
		{
			var probe = new Shape();
			__renderCommands(probe.graphics, library, false, true);
			hardwareCompatible = Context3DGraphics.isCompatible(probe.graphics);
		}

		if (requiresReadableBitmapData || hardwareCompatible != true)
		{
			__markBitmapFillsReadable(library);
		}
	}

	private function __markBitmapFillsReadable(library:AnimateLibrary):Void
	{
		if (commands != null)
		{
			for (command in commands)
			{
				switch (command)
				{
					case BeginBitmapFill(bitmapID, _, _, _):
						library.__markBitmapDataReadable(cast library.symbols.get(bitmapID));

					default:
				}
			}
		}
	}
	#end

	private function __renderCommands(graphics:openfl.display.Graphics, library:AnimateLibrary, hardwareBitmapFills:Bool, probeBitmapFills:Bool):Void
	{
		for (command in commands)
		{
			switch (command)
			{
				case BeginFill(color, alpha):
					graphics.beginFill(color, alpha);

				case BeginBitmapFill(bitmapID, matrix, repeat, smooth):
					__beginBitmapFill(graphics, library, bitmapID, matrix, repeat, smooth, hardwareBitmapFills, probeBitmapFills);

				case BeginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio):
					#if flash
					var colors:Array<UInt> = cast colors;
					#end
					graphics.beginGradientFill(GradientType.fromInt(fillType), colors, alphas, ratios, matrix, SpreadMethod.fromInt(spreadMethod),
						InterpolationMethod.fromInt(interpolationMethod), focalPointRatio);

				case CurveTo(controlX, controlY, anchorX, anchorY):
					graphics.curveTo(controlX, controlY, anchorX, anchorY);

				case EndFill:
					graphics.endFill();

				case LineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):
					if (thickness != null)
					{
						graphics.lineStyle(thickness, color, alpha, pixelHinting, LineScaleMode.fromInt(scaleMode), CapsStyle.fromInt(caps),
							JointStyle.fromInt(joints), miterLimit);
					}
					else
					{
						graphics.lineStyle();
					}

				case LineTo(x, y):
					graphics.lineTo(x, y);

				case MoveTo(x, y):
					graphics.moveTo(x, y);
			}
		}
	}

	private static function __beginBitmapFill(graphics:openfl.display.Graphics, library:AnimateLibrary, bitmapID:Int, matrix:openfl.geom.Matrix, repeat:Bool,
			smooth:Bool, hardwareBitmapFill:Bool, probeBitmapFill:Bool):Void
	{
		#if lime
		var bitmapSymbol:AnimateBitmapSymbol = cast library.symbols.get(bitmapID);
		#if (!flash && swf_hardware_bitmap_cache)
		var bitmapData:BitmapData;
		if (probeBitmapFill)
		{
			if (__probeBitmapData == null)
			{
				__probeBitmapData = new BitmapData(1, 1, true, 0xFFFFFFFF);
			}
			bitmapData = __probeBitmapData;
		}
		else if (hardwareBitmapFill)
		{
			bitmapData = library.__getHardwareBitmapData(bitmapSymbol);
		}
		else
		{
			// Shapes that fall back to Cairo, including scale9Grid shapes,
			// still need CPU pixels.
			bitmapData = library.__getReadableShapeBitmapData(bitmapSymbol);
		}
		#else
		var bitmap = library.getImage(bitmapSymbol.path);
		var bitmapData = bitmap != null ? BitmapData.fromImage(bitmap) : null;
		#end

		if (bitmapData != null)
		{
			graphics.beginBitmapFill(bitmapData, matrix, repeat, smooth);
		}
		#end
	}
}
