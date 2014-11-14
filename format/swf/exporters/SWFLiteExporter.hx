package format.swf.exporters;


import flash.display.BitmapData;
import flash.text.TextFormatAlign;
import format.swf.exporters.core.FilterType;
import format.swf.exporters.core.ShapeCommand;
import format.swf.instance.Bitmap;
import format.swf.lite.SWFLite;
import format.swf.lite.symbols.BitmapSymbol;
import format.swf.lite.symbols.DynamicTextSymbol;
import format.swf.lite.symbols.FontSymbol;
import format.swf.lite.symbols.ShapeSymbol;
import format.swf.lite.symbols.SpriteSymbol;
import format.swf.lite.symbols.StaticTextSymbol;
import format.swf.lite.symbols.SWFSymbol;
import format.swf.lite.timeline.Frame;
import format.swf.lite.timeline.FrameObject;
import format.swf.SWFTimelineContainer;
import format.swf.tags.IDefinitionTag;
import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsJPEG2;
import format.swf.tags.TagDefineBitsLossless;
import format.swf.tags.TagDefineButton;
import format.swf.tags.TagDefineEditText;
import format.swf.tags.TagDefineFont;
import format.swf.tags.TagDefineFont2;
import format.swf.tags.TagDefineFont4;
import format.swf.tags.TagDefineShape;
import format.swf.tags.TagDefineSprite;
import format.swf.tags.TagDefineText;
import format.swf.tags.TagPlaceObject;
import format.swf.tags.TagSymbolClass;
import format.swf.SWFRoot;


class SWFLiteExporter {
	
	
	public var bitmaps:Map <Int, BitmapData>;
	public var filterClasses:Map <String, Bool>;
	public var swfLite:SWFLite;
	
	private var data:SWFRoot;
	

	public function new (data:SWFRoot) {
		
		this.data = data;
		
		bitmaps = new Map <Int, BitmapData> ();
		filterClasses = new Map <String, Bool> ();
		
		swfLite = new SWFLite ();
		swfLite.frameRate = data.frameRate;
		
		addSprite (data, true);
		
		for (tag in data.tags) {
			
			if (Std.is (tag, TagSymbolClass)) {
				
				for (symbol in cast (tag, TagSymbolClass).symbols) {
					
					processSymbol (symbol);
					
				}
				
			}
			
		}
		
	}
	
	
	private function addButton (tag:TagDefineButton):SWFSymbol {
		
		return null;
		
	}
	
	
	private function addBitmap (tag:IDefinitionTag):BitmapSymbol {
		
		var bitmap = new Bitmap (tag);
		
		if (bitmap.bitmapData != null) {
			
			var symbol = new BitmapSymbol ();
			symbol.className = tag.name;
			symbol.id = tag.characterId;
			
			bitmaps.set (symbol.id, bitmap.bitmapData);
			
			symbol.path = "";
			swfLite.symbols.set (symbol.id, symbol);
			
			return symbol;
			
		}
		
		return null;
		
	}
	
	
	private function addFont (tag:IDefinitionTag):FontSymbol {
		
		if (Std.is (tag, TagDefineFont2)) {
			
			var defineFont:TagDefineFont2 = cast tag;
			var symbol = new FontSymbol ();
			symbol.className = defineFont.name;
			symbol.id = defineFont.characterId;
			symbol.glyphs = new Array<Array<ShapeCommand>> ();
			
			for (i in 0...defineFont.glyphShapeTable.length) {
				
				var handler = new ShapeCommandExporter (data);
				defineFont.export (handler, i);
				symbol.glyphs.push (handler.commands);
				
			}
			
			symbol.advances = cast defineFont.fontAdvanceTable.copy ();
			symbol.bold = defineFont.bold;
			symbol.codes = defineFont.codeTable.copy ();
			symbol.italic = defineFont.italic;
			symbol.leading = defineFont.leading;
			symbol.name = defineFont.fontName;
			
			swfLite.symbols.set (symbol.id, symbol);
			
			return symbol;
			
		}
		
		return null;
		
	}
	
	
	private function addShape (tag:TagDefineShape):ShapeSymbol {
		
		var symbol = new ShapeSymbol ();
		symbol.className = tag.name;
		symbol.id = tag.characterId;
		
		var handler = new ShapeCommandExporter (data);
		tag.export (handler);
		
		symbol.commands = handler.commands;
		
		for (command in handler.commands) {
			
			switch (command) {
				
				case BeginBitmapFill (bitmapID, _, _, _):
					
					processTag (cast data.getCharacter (bitmapID));
				
				default:
				
			}
			
		}
		
		swfLite.symbols.set (symbol.id, symbol);
		
		return symbol;
		
	}
	
	
	private function addSprite (tag:SWFTimelineContainer, root:Bool = false):SpriteSymbol {
		
		var symbol = new SpriteSymbol ();
		
		if (Std.is (tag, IDefinitionTag)) {
			
			symbol.className = untyped tag.name;
			symbol.id = untyped tag.characterId;
			
		}
		
		// TODO: Handle more frames, skipping frames without relevant data
		
		var frame = new Frame ();
		frame.label = tag.frames[0].label;
		
		for (object in tag.frames[0].getObjectsSortedByDepth ()) {
			
			var frameObject = new FrameObject ();
			frameObject.id = object.characterId;
			
			processTag (cast data.getCharacter (object.characterId));
			
			var placeTag:TagPlaceObject = cast tag.tags[object.placedAtIndex];
			frameObject.name = placeTag.instanceName;
			
			if (placeTag.matrix != null) {
				
				var matrix = placeTag.matrix.matrix;
				matrix.tx *= (1 / 20);
				matrix.ty *= (1 / 20);
				
				frameObject.matrix = matrix;
				
			}
			
			if (placeTag.colorTransform != null) {
				
				frameObject.colorTransform = placeTag.colorTransform.colorTransform;
				
			}
			
			if (placeTag.hasFilterList) {
				
				var filters:Array<FilterType> = [];
				
				for (surfaceFilter in placeTag.surfaceFilterList) {
					
					var type = surfaceFilter.type;
					
					if (type != null) {
						
						filters.push (surfaceFilter.type);
						//filterClasses.set (Type.getClassName (Type.getClass (surfaceFilter.filter)), true);
						
					}
					
				}
				
				frameObject.filters = filters;
				
			}
			
			frameObject.depth = placeTag.depth;
			frameObject.clipDepth = (placeTag.hasClipDepth ? placeTag.clipDepth : 0);
			
			frame.objects.push (frameObject);
			
		}
		
		symbol.frames.push (frame);
		
		if (root) {
			
			swfLite.root = symbol;
			
		} else {
			
			swfLite.symbols.set (symbol.id, symbol);
			
		}
		
		return symbol;
		
	}
	
	
	private function addDynamicText (tag:TagDefineEditText):DynamicTextSymbol {
		
		var symbol = new DynamicTextSymbol ();
		
		symbol.className = tag.name;
		symbol.id = tag.characterId;
		symbol.border = tag.border;
		
		if (tag.hasTextColor) {
			
			symbol.color = tag.textColor;
			
		}
		
		symbol.fontHeight = tag.fontHeight;
		symbol.multiline = tag.multiline;
		symbol.selectable = !tag.noSelect;
		
		if (tag.hasText) {
			
			symbol.html = tag.html;
			symbol.text = tag.initialText;
			
		}
		
		symbol.leftMargin = tag.leftMargin;
		symbol.rightMargin = tag.rightMargin;
		symbol.indent = tag.indent;
		symbol.leading = tag.leading;
		
		switch (tag.align) {
			
			case 0: symbol.align = TextFormatAlign.LEFT;
			case 1: symbol.align = TextFormatAlign.RIGHT;
			case 2: symbol.align = TextFormatAlign.CENTER;
			case 3: symbol.align = TextFormatAlign.JUSTIFY;
			
		}
		
		symbol.wordWrap = tag.wordWrap;
		
		if (tag.hasFont) {
			
			var font:IDefinitionTag = cast data.getCharacter (tag.fontId);
			
			if (font != null) {
				
				//processTag (font);
				
			}
			
			symbol.fontID = tag.fontId;
			symbol.fontName = cast (font, TagDefineFont2).fontName;
			
		}
		
		var bounds = tag.bounds.rect;
		symbol.x = bounds.x;
		symbol.y = bounds.y;
		symbol.width = bounds.width;
		symbol.height = bounds.height;
		
		swfLite.symbols.set (symbol.id, symbol);
		
		return symbol;
		
	}
	
	
	private function addStaticText (tag:TagDefineText):StaticTextSymbol {
		
		var symbol = new StaticTextSymbol ();
		
		symbol.className = tag.name;
		symbol.id = tag.characterId;
		
		swfLite.symbols.set (symbol.id, symbol);
		
		return symbol;
		
	}
	
	
	private function processSymbol (symbol:format.swf.data.SWFSymbol):Void {
		
		var data = processTag (cast data.getCharacter (symbol.tagId));
		
		if (data != null) {
			
			data.className = symbol.name;
			
		}
		
	}
	
	
	private function processTag (tag:IDefinitionTag):SWFSymbol {
		
		if (!swfLite.symbols.exists (tag.characterId)) {
			
			if (Std.is (tag, TagDefineSprite)) {
				
				return addSprite (cast tag);
				
			} else if (Std.is (tag, TagDefineBits) || Std.is (tag, TagDefineBitsJPEG2) || Std.is (tag, TagDefineBitsLossless)) {
				
				return addBitmap (tag);
				
			} else if (Std.is (tag, TagDefineButton)) {
				
				return addButton (cast tag);
				
			} else if (Std.is (tag, TagDefineEditText)) {
				
				return addDynamicText (cast tag);
				
			} else if (Std.is (tag, TagDefineText)) {
				
				return addStaticText (cast tag);
					
			} else if (Std.is (tag, TagDefineShape)) {
				
				return addShape (cast tag);
				
			} else if (Std.is (tag, TagDefineFont) || Std.is (tag, TagDefineFont4)) {
				
				return addFont (tag);
				
			}
			
			return null;
			
		} else {
			
			return swfLite.symbols.get (tag.characterId);
			
		}
		
	}
	
	
}