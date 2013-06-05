package format.swf.data;

import format.swf.SWFData;

class SWFMorphGradient
{
	// Forward declarations of properties in SWFMorphFocalGradient
	public var startFocalPoint:Float;
	public var endFocalPoint:Float;
	
	public var records(default, null):Array<SWFMorphGradientRecord>;
	
	public function new(data:SWFData = null, level:Int = 1) {
		records = new Array <SWFMorphGradientRecord>();
		if (data != null) {
			parse(data, level);
		}
	}
	
	public function parse(data:SWFData, level:Int):Void {
		var numGradients:Int = data.readUI8();
		for (i in 0...numGradients) {
			records.push(data.readMORPHGRADIENTRECORD());
		}
	}
	
	public function publish(data:SWFData, level:Int):Void {
		var numGradients:Int = records.length;
		data.writeUI8(numGradients);
		for (i in 0...numGradients) {
			data.writeMORPHGRADIENTRECORD(records[i]);
		}
	}
	
	public function getMorphedGradient(ratio:Float = 0):SWFGradient {
		var gradient:SWFGradient = new SWFGradient();
		for(i in 0...records.length) {
			gradient.records.push(records[i].getMorphedGradientRecord(ratio)); 
		}
		return gradient;
	}
	
	public function toString():String {
		return "(" + records.join(",") + ")";
	}
}