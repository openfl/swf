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
		
		graphics.clear ();
		
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
		var color = editText.hasTextColor ? (editText.textColor & 0xFFFFFF) : 0x000000;
		var alpha = editText.hasTextColor ? ((editText.textColor >> 24) & 0xFF) / 0xFF : 1; 
		var scale = (editText.fontHeight / 1024) * 0.05;
		//scrollRect = editText.bounds.rect;
		
		var x = 0.;
		//var x = editText.leftMargin * scale * 0.05;
		
		for (i in 0..._text.length) {
			
			var index = -1;
			
			for (j in 0...font.codeTable.length) {
				
				if (font.codeTable[j] == _text.charCodeAt (i)) {
					
					index = j;
					
				}
				
			}
			
			if (index > -1) {
				
				graphics.lineStyle ();
				graphics.beginFill (color, alpha);
				
				renderGlyph (font, index, scale, x, font.ascent * scale * 0.05);
				
				graphics.endFill ();
				
				//var colorTransform = new ColorTransform ();
				//colorTransform.color = color;
				//shape.transform.colorTransform = colorTransform;
				
				x += scale * font.fontAdvanceTable[index] * 0.05;
				
			}
			
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
	
	
	private function renderStatic ():Void {
		
		var defineText:TagDefineText = cast tag;
		
		var matrix = null;
		var cacheMatrix = null;
		var tx = defineText.textMatrix.matrix.tx * 0.05;
		var ty = defineText.textMatrix.matrix.ty * 0.05;
		var color = 0x000000;
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
				
				graphics.lineStyle ();
				graphics.beginFill (color, alpha);
				
				renderGlyph (cast data.getCharacter (record.fontId), record.glyphEntries[i].index, matrix.a, matrix.tx, matrix.ty);
				
				graphics.endFill ();
				matrix.tx += record.glyphEntries[i].advance * 0.05;
				
			}
			
		}
		
	}
	
	
	private function stripHTML (html:String):String {
		
		var ereg = new EReg ("<.*?>", "g");
		return ereg.replace (html, "");
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_text ():String {
		
		return _text;
		
	}
	
	
	private function set_text (value:String):String {
		
		if (_text != value && Std.is (tag, TagDefineEditText)) {
			
			_text = value;
			render ();
			
		}
		
		return _text;
		
	}
	
	
}