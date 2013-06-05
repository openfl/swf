package format.swf.exporters.core;


typedef ShapeCommand = {
	
	var type:CommandType;
	var params:Array<Dynamic>;
	
}


enum CommandType {
	
	BEGIN_FILL;
	BEGIN_BITMAP_FILL;
	BEGIN_GRADIENT_FILL;
	END_FILL;
	LINE_STYLE;
	MOVE_TO;
	LINE_TO;
	CURVE_TO;
	
}