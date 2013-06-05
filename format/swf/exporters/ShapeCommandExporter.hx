package format.swf.exporters;


import flash.display.CapsStyle;
import flash.display.GradientType;
import flash.display.InterpolationMethod;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.SpreadMethod;
import flash.geom.Matrix;
import format.swf.SWFTimelineContainer;
import format.swf.exporters.core.DefaultShapeExporter;
import format.swf.exporters.core.ShapeCommand;
import format.swf.utils.NumberUtils;
import format.swf.utils.StringUtils;


class ShapeCommandExporter extends DefaultShapeExporter {
	
	
	public var commands:Array<ShapeCommand>;
	
	
	public function new (swf:SWFTimelineContainer) {
		
		super (swf);
		
		
		
	}
	
	
	override public function beginShape ():Void {
		
		commands = new Array<ShapeCommand> ();
		
	}
	
	
	override public function beginFills ():Void {
		
		commands.push ( { type: CommandType.LINE_STYLE, params: [] } );
		
	}
	
	
	override public function beginLines ():Void {
		
		
		
	}
	
	
	override public function beginFill (color:Int, alpha:Float = 1.0):Void {
		
		commands.push ( { type: CommandType.BEGIN_FILL, params: [ color, alpha ] } );
		
	}
	
	override public function beginGradientFill(type:GradientType, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Float>, matrix:Matrix = null, spreadMethod:SpreadMethod = null, interpolationMethod:InterpolationMethod = null, focalPointRatio:Float = 0):Void {
		
		commands.push ( { type: CommandType.BEGIN_GRADIENT_FILL, params: [ type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio ] } );
		
	}

	override public function beginBitmapFill(bitmapId:Int, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false):Void {
		
		commands.push ( { type: CommandType.BEGIN_BITMAP_FILL, params: [ bitmapId, matrix, repeat, smooth ] } );
		
	}
	
	override public function endFill():Void {
		
		commands.push ( { type: CommandType.END_FILL, params: [] } );
		
	}
	
	override public function lineStyle(thickness:Float = 0, color:Int = 0, alpha:Float = 1.0, pixelHinting:Bool = false, scaleMode:LineScaleMode = null, startCaps:CapsStyle = null, endCaps:CapsStyle = null, joints:JointStyle = null, miterLimit:Float = 3):Void {
		
		commands.push ( { type: CommandType.LINE_STYLE, params: [ thickness, color, alpha, pixelHinting, scaleMode, startCaps, endCaps, joints, miterLimit ] } );
		
	}
	
	
	override public function moveTo(x:Float, y:Float):Void {
		
		commands.push ( { type: CommandType.MOVE_TO, params: [ x, y ] } );
		
	}
	
	override public function lineTo(x:Float, y:Float):Void {
		
		commands.push ( { type: CommandType.LINE_TO, params: [ x, y ] } );
		
	}
	
	override public function curveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float):Void {
		
		commands.push ( { type: CommandType.CURVE_TO, params: [ controlX, controlY, anchorX, anchorY ] } );
		
	}
	
	
}