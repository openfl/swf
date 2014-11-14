package format.swf.lite;


import flash.display.Shape;
import flash.geom.Point;
import format.swf.lite.symbols.FontSymbol;
import format.swf.lite.symbols.TextSymbol;
import format.swf.lite.SWFLite;


class StaticTextField extends Shape {
	
	
	private var symbol:TextSymbol;
	
	
	public function new (swf:SWFLite, symbol:TextSymbol) {
		
		super ();
		
		this.symbol = symbol;
		
		if (symbol.text != null && swf.symbols.exists (symbol.fontID)) {
			
			var font:FontSymbol = cast swf.symbols.get (symbol.fontID);
			var scale = (symbol.fontHeight / 1024) * 0.05;
			var x = 0.0;
			var y = font.ascent * scale * 0.05;
			
			for (i in 0...symbol.text.length) {
				
				var index = -1;
				
				for (j in 0...font.codes.length) {
					
					if (font.codes[j] == symbol.text.charCodeAt (i)) {
						
						index = j;
						
					}
					
				}
				
				if (index > -1) {
					
					renderGlyph (font, index, scale, x, y);
					x += scale * font.advances[index] * 0.05;
					
				}
				
			}
			
		}
		
	}
	
	
	private function renderGlyph (font:FontSymbol, character:Int, scale:Float, offsetX:Float, offsetY:Float):Void {
		
		for (command in font.glyphs[character]) {
			
			switch (command) {
				
				case BeginFill (color, alpha):
					
					beginFill (color != null ? color & 0xFFFFFF : 0x000000, color != null ? ((color >> 24) & 0xFF) / 0xFF : 1);
				
				case CurveTo (controlX, controlY, anchorX, anchorY):
					
					#if (cpp || neko)
					cacheAsBitmap = true;
					#end
					curveTo (controlX * scale + offsetX, controlY * scale + offsetY, anchorX * scale + offsetX, anchorY * scale + offsetY);
				
				case EndFill:
					
					graphics.endFill ();
				
				case LineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit):
					
					if (thickness != null) {
						
						graphics.lineStyle (thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
						
					} else {
						
						graphics.lineStyle ();
						
					}
				
				case LineTo (x, y):
					
					lineTo (x * scale + offsetX, y * scale + offsetY);
				
				case MoveTo (x, y):
					
					moveTo (x * scale + offsetX, y * scale + offsetY);
				
				default:
				
			}
			
		}
		
	}
	
	
}