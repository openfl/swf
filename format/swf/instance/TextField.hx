package format.swf.instance;


import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import format.swf.exporters.ShapeCommandExporter;
import format.swf.tags.IDefinitionTag;
import format.swf.tags.TagDefineEditText;
import format.swf.tags.TagDefineFont;
import format.swf.tags.TagDefineFont2;
import format.swf.tags.TagDefineText;
import format.swf.SWFTimelineContainer;


class TextField extends Sprite {
	
	
	private var data:SWFTimelineContainer;
	private var glyphs:Array<Shape>;
	
	
	public function new (data:SWFTimelineContainer, tag:IDefinitionTag) {
		
		super ();
		
		this.data = data;
		glyphs = new Array<Shape> ();
		
		if (Std.is (tag, TagDefineText)) {
			
			createText (cast tag);
			
		} else {
			
			createEditText (cast tag);
			
		}
		
	}
	
	
	private function createEditText (tag:TagDefineEditText):Void {
		
		/*if (tag.hasFont) {
			
			var font:TagDefineFont2 = cast data.getCharacter (tag.fontId);
			var color = tag.hasTextColor ? tag.textColor : 0x000000;
			
			if (tag.hasText) {
				
				tag.initialText = "hello";
				
				for (i in 0...tag.initialText.length) {
					
					var shape = new Shape ();
					shape.graphics.lineStyle ();
					shape.graphics.beginFill (color, 1);
					
					render (font, font.codeTable[tag.initialText.charCodeAt(i)], shape);
					
					trace (shape.width);
					
					//shape.transform.matrix = matrix;
					//matrix.tx += record.glyphEntries[i].advance * 0.05;
					
					glyphs.push (shape);
					addChild (shape);
					
				}
				
			}
			
		} else {*/
			
			var textField = new flash.text.TextField ();
			textField.selectable = !tag.noSelect;
			
			var rect:Rectangle = tag.bounds.rect;
			
			textField.width = rect.width;
			textField.height = rect.height;
			textField.multiline = tag.multiline;
			textField.wordWrap = tag.wordWrap;
			textField.displayAsPassword = tag.password;
			textField.border = tag.border;
			textField.selectable = !tag.noSelect;
			
			var format = new TextFormat ();
			if (tag.hasTextColor) format.color = tag.textColor;
			//if (hasFont) format.font = symbol.fontId?
			//else if (hasFontClass) format.font = symbol.fontClass?
			
			if (tag.hasFont) {
				
				var font = data.getCharacter (tag.fontId);
				
				if (Std.is (font, TagDefineFont2)) {
					
					format.font = cast (font, TagDefineFont2).fontName;
					//textField.embedFonts = true;
					
				}
				
			}
			
			format.leftMargin = tag.leftMargin;
			format.rightMargin = tag.rightMargin;
			format.indent = tag.indent;
			format.leading = tag.leading;
			
			switch (tag.align) {
				
				case 0: format.align = TextFormatAlign.LEFT;
				case 1: format.align = TextFormatAlign.RIGHT;
				case 2: format.align = TextFormatAlign.CENTER;
				case 3: format.align = TextFormatAlign.JUSTIFY;
				
			}
			
			textField.defaultTextFormat = format;
			
			if (tag.hasText) {
				
				if (tag.html) {
					
					textField.htmlText = tag.initialText;
					
				} else {
					
					textField.text = tag.initialText;
						
				}
				
			}
			
			textField.autoSize = (tag.autoSize) ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
			addChild (textField);
			
		//}
		
	}
	
	
	private function createText (tag:TagDefineText):Void {
		
		var matrix = null;
		var cacheMatrix = null;
		var tx = tag.textMatrix.matrix.tx * 0.05;
		var ty = tag.textMatrix.matrix.ty * 0.05;
		var color = 0;
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
				
				var shape = new Shape ();
				shape.graphics.lineStyle ();
				shape.graphics.beginFill (color, alpha);
				
				render (cast data.getCharacter (record.fontId), record.glyphEntries[i].index, shape);
				
				shape.graphics.endFill ();
				shape.transform.matrix = matrix;
				matrix.tx += record.glyphEntries[i].advance * 0.05;
				
				glyphs.push (shape);
				addChild (shape);
				
			}
			
		}
		
	}
	
	
	private function render (font:TagDefineFont, character:Int, shape:Shape):Void {
		
		var handler = new ShapeCommandExporter (data);
		font.export (handler, character);
		
		trace (handler.commands);
		//trace (character);
		
		for (command in handler.commands) {
			
			switch (command.type) {
				
				case BEGIN_FILL: shape.graphics.beginFill (command.params[0], command.params[1]);
				case END_FILL: shape.graphics.endFill ();
				case LINE_STYLE: 
					
					if (command.params.length > 0) {
						
						shape.graphics.lineStyle (command.params[0], command.params[1], command.params[2], command.params[3], command.params[4], command.params[5], command.params[6], command.params[7]);
						
					} else {
						
						shape.graphics.lineStyle ();
						
					}
				
				case MOVE_TO: shape.graphics.moveTo (command.params[0], command.params[1]);
				case LINE_TO: shape.graphics.lineTo (command.params[0], command.params[1]);
				case CURVE_TO: 
					
					shape.cacheAsBitmap = true;
					shape.graphics.curveTo (command.params[0], command.params[1], command.params[2], command.params[3]);
					
				default:
				
			}
			
		}
		
	}
	
	
}