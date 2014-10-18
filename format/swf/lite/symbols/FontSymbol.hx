package format.swf.lite.symbols;


import format.swf.exporters.core.ShapeCommand;
import openfl.geom.Matrix;


class FontSymbol extends SWFSymbol {
	
	
	public var advances:Array<Float>;
	public var ascent:Int;
	public var codes:Array<Int>;
	public var glyphs:Array<Array<ShapeCommand>>;
	
	
	public function new () {
		
		super ();
		
		type = "font";
		
	}
	
	
	public override function parse (data:Dynamic):Void {
		
		super.parse (data);
		
		advances = data.advances;
		ascent = data.ascent;
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
							
							if (params[4] != null) {
								
								params[4] = new Matrix ();
								params[4].a = commandData.params[4].a;
								params[4].b = commandData.params[4].b;
								params[4].c = commandData.params[4].c;
								params[4].d = commandData.params[4].d;
								params[4].tx = commandData.params[4].tx;
								params[4].ty = commandData.params[4].ty;
								
							}
						
						default:
							
					}
					
					var command:ShapeCommand = { type: type, params: params };
					commands.push (command);
					
				}
				
				glyphs.push (commands);
				
			}
			
		}
		
	}
	
	
	public override function prepare ():Dynamic {
		
		var data:Dynamic = {};
		data.id = id;
		data.className = className;
		data.type = type;
		
		data.advances = advances;
		data.ascent = ascent;
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
							
							commandData.params = [ command.params[0], command.params[1], command.params[2], command.params[3], null, command.params[5], command.params[6], command.params[7] ];
							
							if (command.params[4] != null) {
								
								commandData.params[4] = {};
								commandData.params[4].a = command.params[4].a;
								commandData.params[4].b = command.params[4].b;
								commandData.params[4].c = command.params[4].c;
								commandData.params[4].d = command.params[4].d;
								commandData.params[4].tx = command.params[4].tx;
								commandData.params[4].ty = command.params[4].ty;
								
							}
						
						default:
							
							commandData.params = command.params;
						
					}
					
					commands.push (commandData);
					
				}
				
				data.glyphs.push (commands);
				
			}
			
		}
		
		return data;
		
	}
	
	
}