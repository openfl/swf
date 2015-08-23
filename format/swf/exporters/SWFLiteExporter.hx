package format.swf.exporters;


import flash.display.BitmapData;
import flash.text.TextFormatAlign;
import format.swf.data.SWFButtonRecord;
import format.swf.exporters.core.FilterType;
import format.swf.exporters.core.ShapeCommand;
import format.swf.instance.Bitmap;
import format.swf.lite.symbols.BitmapSymbol;
import format.swf.lite.symbols.ButtonSymbol;
import format.swf.lite.symbols.DynamicTextSymbol;
import format.swf.lite.symbols.FontSymbol;
import format.swf.lite.symbols.ShapeSymbol;
import format.swf.lite.symbols.SpriteSymbol;
import format.swf.lite.symbols.StaticTextSymbol;
import format.swf.lite.symbols.SWFSymbol;
import format.swf.lite.timeline.Frame;
import format.swf.lite.timeline.FrameObject;
import format.swf.lite.SWFLite;
import format.swf.tags.IDefinitionTag;
import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsJPEG2;
import format.swf.tags.TagDefineBitsLossless;
import format.swf.tags.TagDefineButton;
import format.swf.tags.TagDefineButton2;
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
import format.swf.SWFTimelineContainer;


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
	
	
	private function addButton (tag:IDefinitionTag):SWFSymbol {
		
		var symbol = new ButtonSymbol ();
		
		if (Std.is (tag, IDefinitionTag)) {
			
			symbol.id = untyped tag.characterId;
			
		}
		
		var processRecords = function (records:Array<SWFButtonRecord>) {
			
			if (records.length > 0) {
				
				var sprite = new SpriteSymbol ();
				var frame = new Frame ();
				
				for (i in 0...records.length) {
					
					var object = records[i];
					
					var frameObject = new FrameObject ();
					frameObject.id = object.characterId;
					
					processTag (cast data.getCharacter (object.characterId));
					
					if (object.placeMatrix != null) {
						
						var matrix = object.placeMatrix.matrix;
						matrix.tx *= (1 / 20);
						matrix.ty *= (1 / 20);
						
						frameObject.matrix = matrix;
						
					}
					
					if (object.colorTransform != null) {
						
						frameObject.colorTransform = object.colorTransform.colorTransform;
						
					}
					
					if (object.hasFilterList) {
						
						var filters:Array<FilterType> = [];
						
						for (filter in object.filterList) {
							
							var type = filter.type;
							
							if (type != null) {
								
								filters.push (filter.type);
								//filterClasses.set (Type.getClassName (Type.getClass (surfaceFilter.filter)), true);
								
							}
							
						}
						
						frameObject.filters = filters;
						
					}
					
					frameObject.depth = i;
					frameObject.clipDepth = 0;
					
					frame.objects.push (frameObject);
					
				}
				
				sprite.frames.push (frame);
				
				return sprite;
				
			}
			
			return null;
			
		}
		
		if (Std.is (tag, TagDefineButton)) {
			
			var defineButton:TagDefineButton = cast tag;
			
			symbol.downState = processRecords (defineButton.getRecordsByState (TagDefineButton.STATE_DOWN));
			symbol.hitState = processRecords (defineButton.getRecordsByState (TagDefineButton.STATE_HIT));
			symbol.overState = processRecords (defineButton.getRecordsByState (TagDefineButton.STATE_OVER));
			symbol.upState = processRecords (defineButton.getRecordsByState (TagDefineButton.STATE_UP));
			
		} else {
			
			var defineButton:TagDefineButton2 = cast tag;
			
			symbol.downState = processRecords (defineButton.getRecordsByState (TagDefineButton.STATE_DOWN));
			symbol.hitState = processRecords (defineButton.getRecordsByState (TagDefineButton.STATE_HIT));
			symbol.overState = processRecords (defineButton.getRecordsByState (TagDefineButton.STATE_OVER));
			symbol.upState = processRecords (defineButton.getRecordsByState (TagDefineButton.STATE_UP));
			
		}
		
		swfLite.symbols.set (symbol.id, symbol);
		
		return symbol;
		
	}
	
	
	private function addBitmap (tag:IDefinitionTag):BitmapSymbol {
		
		var bitmap = new Bitmap (tag);
		
		if (bitmap.bitmapData != null) {
			
			var symbol = new BitmapSymbol ();
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
			symbol.id = defineFont.characterId;
			symbol.glyphs = new Array<Array<ShapeCommand>> ();
			
			//for (i in 0...defineFont.glyphShapeTable.length) {
				//
				//var handler = new ShapeCommandExporter (data);
				//defineFont.export (handler, i);
				//symbol.glyphs.push (handler.commands);
				//
			//}
			
			symbol.advances = new Array<Int> ();
			//symbol.advances = cast defineFont.fontAdvanceTable.copy ();
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
			
			symbol.id = untyped tag.characterId;
			
		}
		
		for (i in 0...tag.frames.length) {
		//for (i in 0...1) {
			
			var frame = new Frame ();
			frame.label = tag.frames[i].label;
			
			for (object in tag.frames[i].getObjectsSortedByDepth ()) {
				
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
			
		}
		
		if (root) {
			
			swfLite.root = symbol;
			
		} else {
			
			swfLite.symbols.set (symbol.id, symbol);
			
		}
		
		return symbol;
		
	}
	
	
	private function addDynamicText (tag:TagDefineEditText):DynamicTextSymbol {
		
		var symbol = new DynamicTextSymbol ();
		
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
		
		if (tag.hasLayout) {
			
			switch (tag.align) {
				
				case 0: symbol.align = "left";
				case 1: symbol.align = "right";
				case 2: symbol.align = "center";
				case 3: symbol.align = "justify";
				
			}
			
			symbol.leftMargin = tag.leftMargin;
			symbol.rightMargin = tag.rightMargin;
			symbol.indent = tag.indent;
			symbol.leading = tag.leading;
			
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
		symbol.id = tag.characterId;
		
		var records = [];
		
		for (record in tag.records) {
			
			var textRecord = new StaticTextRecord ();
			var font:FontSymbol = null;
			var defineFont:TagDefineFont2 = null;
			
			if (record.hasFont) {
				
				textRecord.fontID = record.fontId;
				
				defineFont = cast data.getCharacter (record.fontId);
				processTag (defineFont);
				font = cast swfLite.symbols.get (record.fontId);
				
			}
			
			if (record.hasColor) textRecord.color = record.textColor;
			if (record.hasXOffset) textRecord.offsetX = record.xOffset;
			if (record.hasYOffset) textRecord.offsetY= record.yOffset;
			textRecord.fontHeight = record.textHeight;
			
			var advances = [];
			var glyphs = [];
			
			if (font != null) {
				
				var handler = new ShapeCommandExporter (data);
				
				for (glyphEntry in record.glyphEntries) {
					
					var index = glyphEntry.index;
					
					advances.push (glyphEntry.advance);
					glyphs.push (index);
					
					if (font.glyphs[index] == null) {
						
						handler.beginShape ();
						defineFont.export (handler, index);
						font.glyphs[index] = handler.commands.copy ();
						font.advances[index] = defineFont.fontAdvanceTable[index];
						
					}
					
				}
				
			}
			
			textRecord.advances = advances;
			textRecord.glyphs = glyphs;
			records.push (textRecord);
			
		}
		
		symbol.records = records;
		
		var matrix = tag.textMatrix.matrix;
		matrix.tx *= (1 / 20);
		matrix.ty *= (1 / 20);
		
		symbol.matrix = matrix;
		
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
				
			} else if (Std.is (tag, TagDefineButton) || Std.is (tag, TagDefineButton2)) {
				
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