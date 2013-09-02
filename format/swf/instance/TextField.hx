package format.swf.instance;


import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.ColorTransform;
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
	
	
	public var text (get, set):String;
	
	private var _text:String;
	private var data:SWFTimelineContainer;
	private var glyphs:Array<Shape>;
	private var tag:IDefinitionTag;
	
	
	public function new (data:SWFTimelineContainer, tag:IDefinitionTag) {
		
		super ();
		
		this.data = data;
		this.tag = tag;
		
		if (Std.is (tag, TagDefineEditText)) {
			
			if (cast (tag, TagDefineEditText).hasText) {
				
				_text = stripHTML (cast (tag, TagDefineEditText).initialText);
				
			}
			
		}
		
		render ();
		
	}
	
	
	private function render ():Void {
		
		glyphs = new Array<Shape> ();
		
		if (Std.is (tag, TagDefineText)) {
			
			renderStatic ();
			
		} else {
			
			if (cast (tag, TagDefineEditText).hasFont) {
				
				renderDynamic ();
				
			} else {
				
				renderFallback ();
				
			}
			
		}
		
	}
	
	
	private function renderDynamic ():Void {
		
		var editText:TagDefineEditText = cast tag;
		var font:TagDefineFont2 = cast data.getCharacter (editText.fontId);
		var color = editText.hasTextColor ? editText.textColor : 0x000000;
		
		//scrollRect = editText.bounds.rect;
		
		var x = 0.;
		
		for (i in 0..._text.length) {
			
			var shape = new Shape ();
			shape.graphics.lineStyle ();
			shape.graphics.beginFill (color, 1);
			
			var index = 0;
			
			for (j in 0...font.codeTable.length) {
				
				if (font.codeTable[j] == _text.charCodeAt (i)) {
					
					index = j;
					
				}
				
			}
			
			renderGlyph (font, index, shape);
			
			shape.scaleX = shape.scaleY = (editText.fontHeight / 1024) * 0.05;
			
			var colorTransform = new ColorTransform ();
			colorTransform.color = color;
			shape.transform.colorTransform = colorTransform;
			
			var bounds = font.fontBoundsTable[i];
			
			if (bounds != null) {
				
				var rect = bounds.rect;
				if (rect.x != 0)trace (rect);
				
				shape.y = rect.y;
				x += rect.x;
				
			}
			
			shape.x = x;
			x += shape.scaleX * font.fontAdvanceTable[index] * 0.05;
			
			glyphs.push (shape);
			addChild (shape);
			
		}
		
	}
	
	
	private function renderFallback ():Void {
		
		var editText:TagDefineEditText = cast tag;
		var textField = new flash.text.TextField ();
		textField.selectable = !editText.noSelect;
		
		var rect:Rectangle = editText.bounds.rect;
		
		textField.width = rect.width;
		textField.height = rect.height;
		textField.multiline = editText.multiline;
		textField.wordWrap = editText.wordWrap;
		textField.displayAsPassword = editText.password;
		textField.border = editText.border;
		textField.selectable = !editText.noSelect;
		
		var format = new TextFormat ();
		if (editText.hasTextColor) format.color = editText.textColor;
		
		if (editText.hasFont) {
			
			var font = data.getCharacter (editText.fontId);
			
			if (Std.is (font, TagDefineFont2)) {
				
				format.font = cast (font, TagDefineFont2).fontName;
				//textField.embedFonts = true;
				
			}
			
		}
		
		format.leftMargin = editText.leftMargin;
		format.rightMargin = editText.rightMargin;
		format.indent = editText.indent;
		format.leading = editText.leading;
		
		switch (editText.align) {
			
			case 0: format.align = TextFormatAlign.LEFT;
			case 1: format.align = TextFormatAlign.RIGHT;
			case 2: format.align = TextFormatAlign.CENTER;
			case 3: format.align = TextFormatAlign.JUSTIFY;
			
		}
		
		textField.defaultTextFormat = format;
		
		if (editText.hasText) {
			
			//if (editText.html) {
				
				//textField.htmlText = editText.initialText;
				
			//} else {
				
				textField.text = _text;
					
			//}
			
		}
		
		textField.autoSize = (editText.autoSize) ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
		addChild (textField);
		
	}
	
	
	private function renderGlyph (font:TagDefineFont, character:Int, shape:Shape):Void {
		
		var handler = new ShapeCommandExporter (data);
		font.export (handler, character);
		
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
	
	
	private function renderStatic ():Void {
		
		var defineText:TagDefineText = cast tag;
		
		var matrix = null;
		var cacheMatrix = null;
		var tx = defineText.textMatrix.matrix.tx * 0.05;
		var ty = defineText.textMatrix.matrix.ty * 0.05;
		var color = 0;
		var alpha = 1.0;
		
		for (record in defineText.records) {
			
			var scale = (record.textHeight / 1024) * 0.05;
			
			cacheMatrix = matrix;
			matrix = defineText.textMatrix.matrix.clone ();
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
				
				renderGlyph (cast data.getCharacter (record.fontId), record.glyphEntries[i].index, shape);
				
				shape.graphics.endFill ();
				shape.transform.matrix = matrix;
				matrix.tx += record.glyphEntries[i].advance * 0.05;
				
				glyphs.push (shape);
				addChild (shape);
				
			}
			
		}
		
	}
	
	
	private function stripHTML (html:String):String {
		
		var ereg = new EReg ("<.*?>", "g");
		return ereg.replace (html, "");
		
	}
	
	
	private function update ():Void {
		
		for (glyph in glyphs) {
			
			removeChild (glyph);
			
		}
		
		render ();
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_text ():String {
		
		return _text;
		
	}
	
	
	private function set_text (value:String):String {
		
		if (_text != value && Std.is (tag, TagDefineEditText)) {
			
			_text = value;
			update ();
			
		}
		
		return _text;
		
	}
	
	
}