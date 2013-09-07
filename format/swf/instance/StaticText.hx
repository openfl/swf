package format.swf.instance;


import flash.display.Shape;
import format.swf.exporters.ShapeCommandExporter;
import format.swf.tags.TagDefineFont;
import format.swf.tags.TagDefineText;
import format.swf.SWFTimelineContainer;


class StaticText extends Shape {
	
	
	private var data:SWFTimelineContainer;
	private var tag:TagDefineText;
	
	
	public function new (data:SWFTimelineContainer, tag:TagDefineText) {
		
		super ();
		
		var matrix = null;
		var cacheMatrix = null;
		var tx = tag.textMatrix.matrix.tx * 0.05;
		var ty = tag.textMatrix.matrix.ty * 0.05;
		var color = 0x000000;
		var alpha = 1.0;
		
		for (record in tag.records) {
			
			var scale = (record.textHeight / 1024) * 0.05;
			
			cacheMatrix = matrix;
			matrix = tag.textMatrix.matrix.clone ();
			matrix.scale (scale, scale);
			
			if (record.hasColor) {
				
				color = record.textColor & 0x00FFFFFF;
				alpha = (record.textColor & 0xFF) / 0xFF;
				
			}
			
			if (cacheMatrix != null && (record.hasColor || record.hasFont) && (!record.hasXOffset && !record.hasYOffset)) {
				
				matrix.tx = cacheMatrix.tx;
				matrix.ty = cacheMatrix.ty;
				
			} else {
				
				matrix.tx = tx + (record.xOffset) * 0.05;
				matrix.ty = ty + (record.yOffset) * 0.05;
				
			}
			
			for (i in 0...record.glyphEntries.length) {
				
				graphics.lineStyle ();
				graphics.beginFill (color, alpha);
				
				renderGlyph (cast data.getCharacter (record.fontId), record.glyphEntries[i].index, matrix.a, matrix.tx, matrix.ty);
				
				graphics.endFill ();
				matrix.tx += record.glyphEntries[i].advance * 0.05;
				
			}
			
		}
		
	}
	
	
	private function renderGlyph (font:TagDefineFont, character:Int, scale:Float, offsetX:Float, offsetY:Float):Void {
		
		var handler = new ShapeCommandExporter (data);
		font.export (handler, character);
		
		for (command in handler.commands) {
			
			switch (command.type) {
				
				//case BEGIN_FILL: graphics.beginFill (command.params[0], command.params[1]);
				//case END_FILL: graphics.endFill ();
				case LINE_STYLE: 
					
					if (command.params.length > 0) {
						
						graphics.lineStyle (command.params[0], command.params[1], command.params[2], command.params[3], command.params[4], command.params[5], command.params[6], command.params[7]);
						
					} else {
						
						graphics.lineStyle ();
						
					}
				
				case MOVE_TO: graphics.moveTo (command.params[0] * scale + offsetX, command.params[1] * scale + offsetY);
				case LINE_TO: graphics.lineTo (command.params[0] * scale + offsetX, command.params[1] * scale + offsetY);
				case CURVE_TO: 
					
					cacheAsBitmap = true;
					graphics.curveTo (command.params[0] * scale + offsetX, command.params[1] * scale + offsetY, command.params[2] * scale + offsetX, command.params[3] * scale + offsetY);
					
				default:
				
			}
			
		}
		
	}
	
	
}