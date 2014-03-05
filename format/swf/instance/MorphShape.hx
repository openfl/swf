package format.swf.instance;


import format.swf.exporters.ShapeCommandExporter;
import format.swf.instance.Bitmap;
import format.swf.tags.TagDefineMorphShape;
import format.swf.SWFTimelineContainer;


class MorphShape extends flash.display.Shape {
	
	private var tag:TagDefineMorphShape;
	private var handler:ShapeCommandExporter;
	private var data:SWFTimelineContainer;
	
	public function new (data:SWFTimelineContainer, tag:TagDefineMorphShape) {
		
		super ();
		
		handler = new ShapeCommandExporter (data);
		this.tag = tag;
		this.tag.exportHandler = handler;
		this.data = data;
		
		//render();
		
		//if (tag != null) {
			
			//var handler = new ShapeCommandExporter (data);
			//tag.export (handler);
			//....
			
			
		//}
		
	}
	
	
	public function render (ratio:Float = 0):Void {
		
		tag.export(ratio / 65536.0);
		graphics.clear();
		for (command in handler.commands) {
				
			switch (command.type) {
				
				case BEGIN_FILL: graphics.beginFill (command.params[0], command.params[1]);
				case BEGIN_GRADIENT_FILL: 
					
					cacheAsBitmap = true;
					graphics.beginGradientFill (command.params[0], command.params[1], command.params[2], command.params[3], command.params[4], command.params[5], command.params[6], command.params[7]);
				
				case BEGIN_BITMAP_FILL: 
					
					var bitmap = new Bitmap (cast data.getCharacter (command.params[0]));
					
					if (bitmap.bitmapData != null) {
						
						graphics.beginBitmapFill (bitmap.bitmapData, command.params[1], command.params[2], command.params[3]);
						
					}
					
				case END_FILL: graphics.endFill ();
				case LINE_STYLE: 
					
					if (command.params.length > 0) {
						
						graphics.lineStyle (command.params[0], command.params[1], command.params[2], command.params[3], command.params[4], command.params[5], command.params[6], command.params[7]);
						
					} else {
						
						graphics.lineStyle ();
						
					}
				
				case MOVE_TO: graphics.moveTo (command.params[0], command.params[1]); /*trace("moveTo( " + command.params[0] + ", " + command.params[1] + ")");*/
				case LINE_TO: graphics.lineTo (command.params[0], command.params[1]); /*trace("lineTo( " + command.params[0] + ", " + command.params[1] + ")");*/
				case CURVE_TO: 
					
					//cacheAsBitmap = true;
					graphics.curveTo (command.params[0], command.params[1], command.params[2], command.params[3]);
					//trace("curveTo( " + command.params[0] + ", " + command.params[1] + ", " + command.params[2] + ", " + command.params[3] + ")");
				
			}
			
		}
		
	}
	
}