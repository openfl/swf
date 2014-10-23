package format.swf.lite.symbols;


import flash.display.CapsStyle;
import flash.display.GradientType;
import flash.display.InterpolationMethod;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.SpreadMethod;
import format.swf.exporters.core.ShapeCommand;
import openfl.geom.Matrix;


class FontSymbol extends SWFSymbol {
	
	
	public var advances:Array<Float>;
	public var bold:Bool;
	public var codes:Array<Int>;
	public var glyphs:Array<Array<ShapeCommand>>;
	public var italic:Bool;
	public var leading:Int;
	public var name:String;
	
	
	public function new () {
		
		super ();
		
		type = "font";
		
	}
	
	
	public override function parse (data:Dynamic):Void {
		
		super.parse (data);
		
		advances = data.advances;
		bold = data.bold;
		codes = data.codes;
		
		if (data.glyphs != null) {
			
			glyphs = [];
			
			for (glyphData in cast (data.glyphs, Array<Dynamic>)) {
				
				var commands = [];
				
				for (commandData in cast (glyphData, Array<Dynamic>)) {
					
					var type = Type.createEnumIndex (CommandType, commandData.type);
					var params:Array<Dynamic> = commandData.params.copy ();
					
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
							
							params[0] = if (params[0] != null) Type.createEnum (GradientType, params[0]);
							
							if (params[4] != null) {
								
								params[4] = new Matrix ();
								params[4].a = commandData.params[4].a;
								params[4].b = commandData.params[4].b;
								params[4].c = commandData.params[4].c;
								params[4].d = commandData.params[4].d;
								params[4].tx = commandData.params[4].tx;
								params[4].ty = commandData.params[4].ty;
								
							}
							
							params[5] = if (params[5] != null) Type.createEnum (SpreadMethod, params[5]);
							params[6] = if (params[6] != null) Type.createEnum (InterpolationMethod, params[6]);
						
						case LINE_STYLE:
							
							params[4] = if (params[4] != null) Type.createEnum (LineScaleMode, params[4]);
							params[5] = if (params[5] != null) Type.createEnum (CapsStyle, params[5]);
							params[6] = if (params[6] != null) Type.createEnum (JointStyle, params[6]);
						
						default:
							
					}
					
					var command:ShapeCommand = { type: type, params: params };
					commands.push (command);
					
				}
				
				glyphs.push (commands);
				
			}
			
		}
		
		italic = data.italic;
		leading = data.leading;
		name = data.name;
		
	}
	
	
	public override function prepare ():Dynamic {
		
		var data:Dynamic = {};
		data.id = id;
		data.className = className;
		data.type = type;
		
		data.advances = advances;
		data.bold = bold;
		data.codes = codes;
		
		data.glyphs = [];
		
		if (glyphs != null) {
			
			for (glyph in glyphs) {
				
				var commands = [];
				
				for (command in glyph) {
					
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
							
							commandData.params = [ null, command.params[1], command.params[2], command.params[3], null, null, null, command.params[7] ];
							
							if (command.params[0] != null) {
								
								commandData.params[0] = Std.string (command.params[0]);
								
							}
							
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
								
								commandData.params[5] = Std.string (command.params[5]);
								
							}
							
							if (command.params[6] != null) {
								
								commandData.params[6] = Std.string (command.params[6]);
								
							}
						
						case LINE_STYLE:
							
							commandData.params = [ command.params[0], command.params[1], command.params[2], command.params[3], null, null, null, command.params[7] ];
							
							if (command.params[4] != null) {
								
								commandData.params[4] = Std.string (command.params[4]);
								
							}
							
							if (command.params[5] != null) {
								
								commandData.params[5] = Std.string (command.params[5]);
								
							}
							
							if (command.params[6] != null) {
								
								commandData.params[6] = Std.string (command.params[6]);
								
							}
						
						default:
							
							commandData.params = command.params;
						
					}
					
					commands.push (commandData);
					
				}
				
				data.glyphs.push (commands);
				
			}
			
		}
		
		data.italic = italic;
		#if neko
		data.leading = (leading != null) ? leading : 0;
		#else
		data.leading = leading;
		#end
		data.name = name;
		
		return data;
		
	}
	
	
}