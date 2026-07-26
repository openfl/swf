package swf.exporters.animate;

import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.GradientType;
import openfl.display.InterpolationMethod;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Shape;
import openfl.display.SpreadMethod;
import swf.exporters.animate.AnimateLibrary.SWFShapeCommandType;

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
class AnimateShapeSymbol extends AnimateSymbol
{
	public var commands:Array<AnimateShapeCommand>;
	public var rendered:Shape;

	private var compactCommands:Array<Float>;

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

		if (compactCommands != null)
		{
			__renderCompactCommands(graphics, library);
		}
		else if (commands != null)
		{
			for (command in commands)
			{
				switch (command)
				{
					case BeginFill(color, alpha):
						graphics.beginFill(color, alpha);

					case BeginBitmapFill(bitmapID, matrix, repeat, smooth):
						__beginBitmapFill(graphics, library, bitmapID, matrix, repeat, smooth);

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

		commands = null;
		compactCommands = null;
		rendered = new Shape();
		rendered.graphics.copyFrom(shape.graphics);

		return shape;
	}

	private static function __beginBitmapFill(graphics:openfl.display.Graphics, library:AnimateLibrary, bitmapID:Int, matrix:openfl.geom.Matrix, repeat:Bool,
			smooth:Bool):Void
	{
		#if lime
		var bitmapSymbol:AnimateBitmapSymbol = cast library.symbols.get(bitmapID);
		var bitmap = library.getImage(bitmapSymbol.path);

		if (bitmap != null)
		{
			graphics.beginBitmapFill(BitmapData.fromImage(bitmap), matrix, repeat, smooth);
		}
		#end
	}

	@:allow(swf.exporters.animate.AnimateLibrary)
	private function __setCompactCommands(data:Array<Dynamic>):Void
	{
		compactCommands = [];
		var i = 0;

		while (i < data.length)
		{
			var type:SWFShapeCommandType = data[i];
			compactCommands.push(cast type);

			switch (type)
			{
				case BEGIN_BITMAP_FILL:
					compactCommands.push(data[i + 1]);
					__encodeMatrix(compactCommands, data[i + 2]);
					compactCommands.push(data[i + 3] ? 1 : 0);
					compactCommands.push(data[i + 4] ? 1 : 0);
					i += 5;

				case BEGIN_FILL:
					compactCommands.push(data[i + 1]);
					compactCommands.push(data[i + 2]);
					i += 3;

				case BEGIN_GRADIENT_FILL:
					__encodeNullableNumber(compactCommands, data[i + 1]);
					__encodeArray(compactCommands, data[i + 2]);
					__encodeArray(compactCommands, data[i + 3]);
					__encodeArray(compactCommands, data[i + 4]);
					__encodeMatrix(compactCommands, data[i + 5]);
					__encodeNullableNumber(compactCommands, data[i + 6]);
					__encodeNullableNumber(compactCommands, data[i + 7]);
					compactCommands.push(data[i + 8]);
					i += 9;

				case CLEAR_LINE_STYLE:
					i++;

				case CURVE_TO:
					compactCommands.push(data[i + 1]);
					compactCommands.push(data[i + 2]);
					compactCommands.push(data[i + 3]);
					compactCommands.push(data[i + 4]);
					i += 5;

				case END_FILL:
					i++;

				case LINE_STYLE:
					__encodeNullableNumber(compactCommands, data[i + 1]);
					__encodeNullableNumber(compactCommands, data[i + 2]);
					__encodeNullableNumber(compactCommands, data[i + 3]);
					__encodeNullableBool(compactCommands, data[i + 4]);
					__encodeNullableNumber(compactCommands, data[i + 5]);
					__encodeNullableNumber(compactCommands, data[i + 6]);
					__encodeNullableNumber(compactCommands, data[i + 7]);
					__encodeNullableNumber(compactCommands, data[i + 8]);
					i += 9;

				case LINE_TO, MOVE_TO:
					compactCommands.push(data[i + 1]);
					compactCommands.push(data[i + 2]);
					i += 3;

				default:
					i++;
			}
		}
	}

	private static function __encodeArray(output:Array<Float>, values:Array<Dynamic>):Void
	{
		if (values == null)
		{
			output.push(-1);
			return;
		}

		output.push(values.length);
		for (value in values)
		{
			output.push(value);
		}
	}

	private static function __encodeMatrix(output:Array<Float>, values:Array<Dynamic>):Void
	{
		if (values == null)
		{
			output.push(0);
			return;
		}

		output.push(1);
		for (i in 0...6)
		{
			output.push(values[i]);
		}
	}

	private static function __encodeNullableBool(output:Array<Float>, value:Dynamic):Void
	{
		output.push(value == null ? Math.NaN : (value ? 1 : 0));
	}

	private static function __encodeNullableNumber(output:Array<Float>, value:Dynamic):Void
	{
		output.push(value == null ? Math.NaN : value);
	}

	private function __renderCompactCommands(graphics:openfl.display.Graphics, library:AnimateLibrary):Void
	{
		var data = compactCommands;
		var position = 0;

		while (position < data.length)
		{
			var type:SWFShapeCommandType = cast Std.int(data[position++]);

			switch (type)
			{
				case BEGIN_BITMAP_FILL:
					var bitmapID = Std.int(data[position++]);
					var matrix = __decodeMatrix(data, position);
					position += data[position] == 0 ? 1 : 7;
					var repeat = data[position++] != 0;
					var smooth = data[position++] != 0;
					__beginBitmapFill(graphics, library, bitmapID, matrix, repeat, smooth);

				case BEGIN_FILL:
					graphics.beginFill(Std.int(data[position++]), data[position++]);

				case BEGIN_GRADIENT_FILL:
					var value = data[position++];
					var fillType:Null<Int> = Math.isNaN(value) ? null : Std.int(value);
					var colors = __decodeIntArray(data, position);
					position += 1 + (colors == null ? 0 : colors.length);
					var alphas = __decodeFloatArray(data, position);
					position += 1 + (alphas == null ? 0 : alphas.length);
					var ratios = __decodeIntArray(data, position);
					position += 1 + (ratios == null ? 0 : ratios.length);
					var matrix = __decodeMatrix(data, position);
					position += data[position] == 0 ? 1 : 7;
					value = data[position++];
					var spreadMethod:Null<Int> = Math.isNaN(value) ? null : Std.int(value);
					value = data[position++];
					var interpolationMethod:Null<Int> = Math.isNaN(value) ? null : Std.int(value);
					var focalPointRatio = data[position++];

					#if flash
					var flashColors:Array<UInt> = cast colors;
					#end
					graphics.beginGradientFill(GradientType.fromInt(fillType), #if flash flashColors #else colors #end, alphas, ratios, matrix,
						SpreadMethod.fromInt(spreadMethod), InterpolationMethod.fromInt(interpolationMethod), focalPointRatio);

				case CLEAR_LINE_STYLE:
					graphics.lineStyle();

				case CURVE_TO:
					graphics.curveTo(data[position++] / 20, data[position++] / 20, data[position++] / 20, data[position++] / 20);

				case END_FILL:
					graphics.endFill();

				case LINE_STYLE:
					var value = data[position++];
					var thickness:Null<Float> = Math.isNaN(value) ? null : value;
					value = data[position++];
					var color:Null<Int> = Math.isNaN(value) ? null : Std.int(value);
					value = data[position++];
					var alpha:Null<Float> = Math.isNaN(value) ? null : value;
					value = data[position++];
					var pixelHinting:Null<Bool> = Math.isNaN(value) ? null : value != 0;
					value = data[position++];
					var scaleMode:Null<Int> = Math.isNaN(value) ? null : Std.int(value);
					value = data[position++];
					var caps:Null<Int> = Math.isNaN(value) ? null : Std.int(value);
					value = data[position++];
					var joints:Null<Int> = Math.isNaN(value) ? null : Std.int(value);
					value = data[position++];
					var miterLimit:Null<Float> = Math.isNaN(value) ? null : value;

					if (thickness != null)
					{
						graphics.lineStyle(thickness, color, alpha, pixelHinting, LineScaleMode.fromInt(scaleMode), CapsStyle.fromInt(caps),
							JointStyle.fromInt(joints), miterLimit);
					}
					else
					{
						graphics.lineStyle();
					}

				case LINE_TO:
					graphics.lineTo(data[position++] / 20, data[position++] / 20);

				case MOVE_TO:
					graphics.moveTo(data[position++] / 20, data[position++] / 20);
			}
		}
	}

	private static function __decodeFloatArray(data:Array<Float>, position:Int):Array<Float>
	{
		var length = Std.int(data[position++]);
		if (length < 0) return null;

		var result = [];
		for (i in 0...length)
		{
			result.push(data[position + i]);
		}
		return result;
	}

	private static function __decodeIntArray(data:Array<Float>, position:Int):Array<Int>
	{
		var length = Std.int(data[position++]);
		if (length < 0) return null;

		var result = [];
		for (i in 0...length)
		{
			result.push(Std.int(data[position + i]));
		}
		return result;
	}

	private static function __decodeMatrix(data:Array<Float>, position:Int):openfl.geom.Matrix
	{
		if (data[position++] == 0) return null;
		return new openfl.geom.Matrix(data[position], data[position + 1], data[position + 2], data[position + 3], data[position + 4] / 20,
			data[position + 5] / 20);
	}
}
