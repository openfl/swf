package swf.tags;

import swf.SWFData;
import swf.data.SWFFillStyle;
import swf.data.SWFLineStyle;
import swf.data.SWFMorphFillStyle;
import swf.data.SWFMorphLineStyle;
import swf.data.SWFRectangle;
import swf.data.SWFShape;
import swf.data.SWFShapeRecord;
import swf.data.SWFShapeRecordCurvedEdge;
import swf.data.SWFShapeRecordEnd;
import swf.data.SWFShapeRecordStraightEdge;
import swf.data.SWFShapeRecordStyleChange;
import swf.exporters.core.IShapeExporter;
import swf.utils.StringUtils;
import openfl.errors.Error;

class TagDefineMorphShape implements IDefinitionTag
{
	public static inline var TYPE:Int = 46;

	public var startBounds:SWFRectangle;
	public var endBounds:SWFRectangle;
	public var startEdges:SWFShape;
	public var endEdges:SWFShape;
	public var type(default, null):Int;
	public var name(default, null):String;
	public var version(default, null):Int;
	public var level(default, null):Int;
	public var characterId:Int;
	public var morphFillStyles(default, null):Array<SWFMorphFillStyle>;
	public var morphLineStyles(default, null):Array<SWFMorphLineStyle>;
	public var exportHandler:IShapeExporter;

	public function new()
	{
		type = TYPE;
		name = "DefineMorphShape";
		version = 3;
		level = 1;

		morphFillStyles = new Array<SWFMorphFillStyle>();
		morphLineStyles = new Array<SWFMorphLineStyle>();
	}

	public function parse(data:SWFData, length:Int, version:Int, async:Bool = false):Void
	{
		characterId = data.readUI16();
		startBounds = data.readRECT();
		endBounds = data.readRECT();
		var offset:Int = data.readUI32();
		var i:Int;
		// MorphFillStyleArray
		var fillStyleCount:Int = data.readUI8();
		if (fillStyleCount == 0xff)
		{
			fillStyleCount = data.readUI16();
		}
		for (i in 0...fillStyleCount)
		{
			morphFillStyles.push(data.readMORPHFILLSTYLE());
		}
		// MorphLineStyleArray
		var lineStyleCount:Int = data.readUI8();
		if (lineStyleCount == 0xff)
		{
			lineStyleCount = data.readUI16();
		}
		for (i in 0...lineStyleCount)
		{
			morphLineStyles.push(data.readMORPHLINESTYLE());
		}
		startEdges = data.readSHAPE();
		endEdges = data.readSHAPE();
	}

	public function publish(data:SWFData, version:Int):Void
	{
		var body:SWFData = new SWFData();
		body.writeUI16(characterId);
		body.writeRECT(startBounds);
		body.writeRECT(endBounds);
		var startBytes:SWFData = new SWFData();
		var i:Int;
		// MorphFillStyleArray
		var fillStyleCount:Int = morphFillStyles.length;
		if (fillStyleCount > 0xfe)
		{
			startBytes.writeUI8(0xff);
			startBytes.writeUI16(fillStyleCount);
		}
		else
		{
			startBytes.writeUI8(fillStyleCount);
		}
		for (i in 0...fillStyleCount)
		{
			startBytes.writeMORPHFILLSTYLE(morphFillStyles[i]);
		}
		// MorphLineStyleArray
		var lineStyleCount:Int = morphLineStyles.length;
		if (lineStyleCount > 0xfe)
		{
			startBytes.writeUI8(0xff);
			startBytes.writeUI16(lineStyleCount);
		}
		else
		{
			startBytes.writeUI8(lineStyleCount);
		}
		for (i in 0...lineStyleCount)
		{
			startBytes.writeMORPHLINESTYLE(morphLineStyles[i]);
		}
		startBytes.writeSHAPE(startEdges);
		body.writeUI32(startBytes.length);
		body.writeBytes(startBytes);
		body.writeSHAPE(endEdges);
		data.writeTagHeader(type, body.length);
		data.writeBytes(body);
	}

	public function clone():IDefinitionTag
	{
		var tag:TagDefineMorphShape = new TagDefineMorphShape();
		throw(new Error("Not implemented yet."));
		return tag;
	}

	public function export(ratio:Float = 0):Void
	{
		getMorphedShape(ratio).export(exportHandler);
	}

	// Interpolates the start and end edges, where a ratio of 0 is the start and 1 is the end
	public function getMorphedShape(ratio:Float = 0):SWFShape
	{
		var shape:SWFShape = new SWFShape();
		for (fillStyle in morphFillStyles)
		{
			shape.fillStyles.push(fillStyle.getMorphedFillStyle(ratio));
		}
		for (lineStyle in morphLineStyles)
		{
			shape.lineStyles.push(lineStyle.getMorphedLineStyle(ratio));
		}

		// End edges only have style change records for moves, and either side can move without the
		// other, so both pen positions are tracked. Positions are rounded instead of deltas, so paths
		// still close at any ratio.
		var startRecords:Array<SWFShapeRecord> = startEdges.records;
		var endRecords:Array<SWFShapeRecord> = endEdges.records;
		var startIndex:Int = 0;
		var endIndex:Int = 0;
		var startX:Int = 0;
		var startY:Int = 0;
		var endX:Int = 0;
		var endY:Int = 0;
		var x:Int = 0;
		var y:Int = 0;

		while (startIndex < startRecords.length && startRecords[startIndex].type != SWFShapeRecord.TYPE_END)
		{
			var startRecord:SWFShapeRecord = startRecords[startIndex];
			var endRecord:SWFShapeRecord = endIndex < endRecords.length ? endRecords[endIndex] : null;

			if (startRecord.type == SWFShapeRecord.TYPE_STYLECHANGE)
			{
				var startStyleChange:SWFShapeRecordStyleChange = cast startRecord;
				var styleChange:SWFShapeRecordStyleChange = cast startStyleChange.clone();
				var moved:Bool = startStyleChange.stateMoveTo;
				if (startStyleChange.stateMoveTo)
				{
					startX = startStyleChange.moveDeltaX;
					startY = startStyleChange.moveDeltaY;
				}
				if (endRecord != null && endRecord.type == SWFShapeRecord.TYPE_STYLECHANGE)
				{
					var endStyleChange:SWFShapeRecordStyleChange = cast endRecord;
					if (endStyleChange.stateMoveTo)
					{
						endX = endStyleChange.moveDeltaX;
						endY = endStyleChange.moveDeltaY;
						moved = true;
					}
					endIndex++;
				}
				if (moved)
				{
					x = interpolate(startX, endX, ratio);
					y = interpolate(startY, endY, ratio);
					styleChange.stateMoveTo = true;
					styleChange.moveDeltaX = x;
					styleChange.moveDeltaY = y;
				}
				shape.records.push(styleChange);
				startIndex++;
			}
			else if (endRecord != null && endRecord.type == SWFShapeRecord.TYPE_STYLECHANGE)
			{
				var endStyleChange:SWFShapeRecordStyleChange = cast endRecord;
				if (endStyleChange.stateMoveTo)
				{
					endX = endStyleChange.moveDeltaX;
					endY = endStyleChange.moveDeltaY;
					var moveTo:SWFShapeRecordStyleChange = new SWFShapeRecordStyleChange();
					x = interpolate(startX, endX, ratio);
					y = interpolate(startY, endY, ratio);
					moveTo.stateMoveTo = true;
					moveTo.moveDeltaX = x;
					moveTo.moveDeltaY = y;
					shape.records.push(moveTo);
				}
				endIndex++;
			}
			else if (endRecord != null && endRecord.isEdgeRecord)
			{
				var startAnchor:Array<Float> = getEdgeAnchor(startRecord, startX, startY);
				var endAnchor:Array<Float> = getEdgeAnchor(endRecord, endX, endY);
				var anchorX:Int = interpolate(startAnchor[0], endAnchor[0], ratio);
				var anchorY:Int = interpolate(startAnchor[1], endAnchor[1], ratio);
				if (startRecord.type == SWFShapeRecord.TYPE_STRAIGHTEDGE && endRecord.type == SWFShapeRecord.TYPE_STRAIGHTEDGE)
				{
					var straightEdge:SWFShapeRecordStraightEdge = new SWFShapeRecordStraightEdge();
					straightEdge.deltaX = anchorX - x;
					straightEdge.deltaY = anchorY - y;
					straightEdge.generalLineFlag = (straightEdge.deltaX != 0 && straightEdge.deltaY != 0);
					straightEdge.vertLineFlag = (straightEdge.deltaX == 0);
					shape.records.push(straightEdge);
				}
				else
				{
					// An edge can change between straight and curved, so a straight edge becomes a curve
					// with its control point in the middle
					var startControl:Array<Float> = getEdgeControl(startRecord, startX, startY);
					var endControl:Array<Float> = getEdgeControl(endRecord, endX, endY);
					var controlX:Int = interpolate(startControl[0], endControl[0], ratio);
					var controlY:Int = interpolate(startControl[1], endControl[1], ratio);
					var curvedEdge:SWFShapeRecordCurvedEdge = new SWFShapeRecordCurvedEdge();
					curvedEdge.controlDeltaX = controlX - x;
					curvedEdge.controlDeltaY = controlY - y;
					curvedEdge.anchorDeltaX = anchorX - controlX;
					curvedEdge.anchorDeltaY = anchorY - controlY;
					shape.records.push(curvedEdge);
				}
				startX = Std.int(startAnchor[0]);
				startY = Std.int(startAnchor[1]);
				endX = Std.int(endAnchor[0]);
				endY = Std.int(endAnchor[1]);
				x = anchorX;
				y = anchorY;
				startIndex++;
				endIndex++;
			}
			else
			{
				throw new Error("The start and end edges of morph shape " + characterId + " do not match");
			}
		}
		shape.records.push(new SWFShapeRecordEnd());
		return shape;
	}

	private static inline function interpolate(start:Float, end:Float, ratio:Float):Int
	{
		return Math.round(start + (end - start) * ratio);
	}

	private static function getEdgeAnchor(record:SWFShapeRecord, x:Int, y:Int):Array<Float>
	{
		if (record.type == SWFShapeRecord.TYPE_CURVEDEDGE)
		{
			var curvedEdge:SWFShapeRecordCurvedEdge = cast record;
			return [
				x + curvedEdge.controlDeltaX + curvedEdge.anchorDeltaX,
				y + curvedEdge.controlDeltaY + curvedEdge.anchorDeltaY
			];
		}
		var straightEdge:SWFShapeRecordStraightEdge = cast record;
		return [x + straightEdge.deltaX, y + straightEdge.deltaY];
	}

	private static function getEdgeControl(record:SWFShapeRecord, x:Int, y:Int):Array<Float>
	{
		if (record.type == SWFShapeRecord.TYPE_CURVEDEDGE)
		{
			var curvedEdge:SWFShapeRecordCurvedEdge = cast record;
			return [x + curvedEdge.controlDeltaX, y + curvedEdge.controlDeltaY];
		}
		var straightEdge:SWFShapeRecordStraightEdge = cast record;
		return [x + straightEdge.deltaX / 2, y + straightEdge.deltaY / 2];
	}

	public function toString(indent:Int = 0):String
	{
		var i:Int;
		var indent2:String = StringUtils.repeat(indent + 2);
		var indent4:String = StringUtils.repeat(indent + 4);
		var str:String = Tag.toStringCommon(type, name, indent) + "ID: " + characterId;
		str += "\n" + indent2 + "Bounds:";
		str += "\n" + indent4 + "StartBounds: " + startBounds.toString();
		str += "\n" + indent4 + "EndBounds: " + endBounds.toString();
		if (morphFillStyles.length > 0)
		{
			str += "\n" + indent2 + "FillStyles:";
			for (i in 0...morphFillStyles.length)
			{
				str += "\n" + indent4 + "[" + (i + 1) + "] " + morphFillStyles[i].toString();
			}
		}
		if (morphLineStyles.length > 0)
		{
			str += "\n" + indent2 + "LineStyles:";
			for (i in 0...morphLineStyles.length)
			{
				str += "\n" + indent4 + "[" + (i + 1) + "] " + morphLineStyles[i].toString();
			}
		}
		str += startEdges.toString(indent + 2);
		str += endEdges.toString(indent + 2);
		return str;
	}
}
