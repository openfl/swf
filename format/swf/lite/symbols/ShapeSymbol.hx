package format.swf.lite.symbols;


import flash.display.CapsStyle;
import flash.display.IGraphicsData;
import flash.display.InterpolationMethod;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.SpreadMethod;
import flash.Vector;
import format.swf.exporters.core.ShapeCommand;
import openfl.geom.Matrix;


class ShapeSymbol extends SWFSymbol {
	
	
	public var commands:Array<ShapeCommand>;
	
	
	public function new () {
		
		super ();
		
		type = "shape";
		
	}
	
	
	public override function parse (data:Dynamic):Void {
		
		super.parse (data);
		
		if (data.commands != null) {
			
			commands = [];
			
			for (commandData in cast (data.commands, Array<Dynamic>)) {
				
				var type = Type.createEnumIndex (CommandType, commandData.type);
				var params = cast (commandData.params, Array<Dynamic>).copy ();
				
				switch (type) {
					
					case BEGIN_BITMAP_FILL:
						
						if (params[1] != null) {
							
							params[1] = new Matrix ();
							params[1].a = commandData.params[1].a;
							params[1].b = commandData.params[1].b;
							params[1].c = commandData.params[1].c;
							params[1].d = commandData.params[1].d;
							params[1].tx = commandData.params[1].tx;
							params[1].ty = commandData.params[1].ty;
							
						}
					
					case BEGIN_GRADIENT_FILL:
						
						if (params[4] != null) {
							
							params[4] = new Matrix ();
							params[4].a = commandData.params[4].a;
							params[4].b = commandData.params[4].b;
							params[4].c = commandData.params[4].c;
							params[4].d = commandData.params[4].d;
							params[4].tx = commandData.params[4].tx;
							params[4].ty = commandData.params[4].ty;
							
						}
						
						if (params[5] != null) {
							
							params[5] = Type.createEnumIndex (SpreadMethod, params[5]);
							
						}
						
						if (params[6] != null) {
							
							params[6] = Type.createEnumIndex (InterpolationMethod, params[6]);
							
						}
					
					case LINE_STYLE:
						
						if (params[4] != null) {
							
							params[4] = Type.createEnumIndex (LineScaleMode, params[4]);
							
						}
						
						if (params[5] != null) {
							
							params[5] = Type.createEnumIndex (CapsStyle, params[5]);
							
						}
						
						if (params[6] != null) {
							
							params[6] = Type.createEnumIndex (JointStyle, params[6]);
							
						}
					
					default:
						
				}
				
				var command:ShapeCommand = { type: type, params: params };
				commands.push (command);
				
			}
			
		}
		
	}
	
	
	public override function prepare ():Dynamic {
		
		var data:Dynamic = {};
		data.id = id;
		data.className = className;
		data.type = type;
		data.commands = [];
		
		if (commands != null) {
			
			for (command in commands) {
				
				var commandData:Dynamic = {};
				commandData.type = Type.enumIndex (command.type);
				
				switch (command.type) {
					
					case BEGIN_BITMAP_FILL:
						
						commandData.params = [ command.params[0], null, command.params[2], command.params[3] ];
						
						if (command.params[1] != null) {
							
							commandData.params[1] = {};
							commandData.params[1].a = command.params[1].a;
							commandData.params[1].b = command.params[1].b;
							commandData.params[1].c = command.params[1].c;
							commandData.params[1].d = command.params[1].d;
							commandData.params[1].tx = command.params[1].tx;
							commandData.params[1].ty = command.params[1].ty;
							
						}
					
					case BEGIN_GRADIENT_FILL:
						
						commandData.params = [ command.params[0], command.params[1], command.params[2], command.params[3], null, null, null, command.params[7] ];
						
						if (command.params[4] != null) {
							
							commandData.params[4] = {};
							commandData.params[4].a = command.params[4].a;
							commandData.params[4].b = command.params[4].b;
							commandData.params[4].c = command.params[4].c;
							commandData.params[4].d = command.params[4].d;
							commandData.params[4].tx = command.params[4].tx;
							commandData.params[4].ty = command.params[4].ty;
							
						}
						
						if (command.params[5] != null) {
							
							commandData.params[5] = Type.enumIndex (command.params[5]);
							
						}
						
						if (command.params[6] != null) {
							
							commandData.params[6] = Type.enumIndex (command.params[6]);
							
						}
					
					case LINE_STYLE:
						
						commandData.params = [ command.params[0], command.params[1], command.params[2], command.params[3], null, null, null, command.params[7] ];
						
						if (command.params[4] != null) {
							
							commandData.params[4] = Type.enumIndex (command.params[4]);
							
						}
						
						if (command.params[5] != null) {
							
							commandData.params[5] = Type.enumIndex (command.params[5]);
							
						}
						
						if (command.params[6] != null) {
							
							commandData.params[6] = Type.enumIndex (command.params[6]);
							
						}
					
					default:
						
						commandData.params = command.params;
					
				}
				
				data.commands.push (commandData);
				
			}
			
		}
		
		return data;
		
	}
	
	
}