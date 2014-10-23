package format.swf.lite.symbols;


import format.swf.lite.timeline.FrameObject;
import format.swf.lite.timeline.Frame;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;


class SpriteSymbol extends SWFSymbol {
	
	
	public var frames:Array <Frame>;
	
	
	public function new () {
		
		super ();
		
		type = "sprite";
		
		frames = new Array <Frame> ();
		
	}
	
	
	public override function parse (data:Dynamic):Void {
		
		super.parse (data);
		
		for (frameData in cast (data.frames, Array<Dynamic>)) {
			
			var frame = new Frame ();
			
			for (objectData in cast (frameData.objects, Array<Dynamic>)) {
				
				var object = new FrameObject ();
				
				if (objectData.colorTransform != null) {
					
					object.colorTransform = new ColorTransform ();
					object.colorTransform.alphaMultiplier = objectData.colorTransform.alphaMultiplier;
					object.colorTransform.alphaOffset = objectData.colorTransform.alphaOffset;
					object.colorTransform.blueMultiplier = objectData.colorTransform.blueMultiplier;
					object.colorTransform.blueOffset = objectData.colorTransform.blueOffset;
					object.colorTransform.greenMultiplier = objectData.colorTransform.greenMultiplier;
					object.colorTransform.greenOffset = objectData.colorTransform.greenOffset;
					object.colorTransform.redMultiplier = objectData.colorTransform.redMultiplier;
					object.colorTransform.redOffset = objectData.colorTransform.redOffset;
						
				}
				
				if (objectData.filters != null) {
					
					object.filters = [];
					
					for (filterData in cast (objectData.filters, Array<Dynamic>)) {
						
						var filter = Type.createInstance (resolveClass (filterData.className), []);
						
						for (field in Reflect.fields (filterData)) {
							
							if (Reflect.hasField (filter, field)) {
								
								Reflect.setField (filter, field, Reflect.field (filterData, field));
								
							}
							
						}
						
						object.filters.push (filter);
						
					}
					
				}
				
				object.id = objectData.id;
				
				if (objectData.matrix != null) {
					
					object.matrix = new Matrix ();
					object.matrix.a = objectData.matrix.a;
					object.matrix.b = objectData.matrix.b;
					object.matrix.c = objectData.matrix.c;
					object.matrix.d = objectData.matrix.d;
					object.matrix.tx = objectData.matrix.tx;
					object.matrix.ty = objectData.matrix.ty;
					
				}
				
				object.name = objectData.name;
				
				frame.objects.push (object);
				
			}
			
			frames.push (frame);
			
		}
		
	}
	
	
	public override function prepare ():Dynamic {
		
		var data:Dynamic = {};
		data.id = id;
		data.className = className;
		data.type = type;
		data.frames = [];
		
		for (frame in frames) {
			
			var frameData:Dynamic = {};
			frameData.label = frame.label;
			frameData.objects = [];
			
			for (object in frame.objects) {
				
				var objectData:Dynamic = {};
				
				if (object.colorTransform != null) {
					
					objectData.colorTransform = {};
					objectData.colorTransform.alphaMultiplier = object.colorTransform.alphaMultiplier;
					objectData.colorTransform.alphaOffset = object.colorTransform.alphaOffset;
					objectData.colorTransform.blueMultiplier = object.colorTransform.blueMultiplier;
					objectData.colorTransform.blueOffset = object.colorTransform.blueOffset;
					objectData.colorTransform.greenMultiplier = object.colorTransform.greenMultiplier;
					objectData.colorTransform.greenOffset = object.colorTransform.greenOffset;
					objectData.colorTransform.redMultiplier = object.colorTransform.redMultiplier;
					objectData.colorTransform.redOffset = object.colorTransform.redOffset;
					
				}
				
				if (object.filters != null) {
					
					objectData.filters = [];
					
					for (filter in object.filters) {
						
						var filterData:Dynamic = { };
						filterData.className = Type.getClassName (Type.getClass (filter));
						
						for (field in Reflect.fields (filter)) {
							
							Reflect.setField (filterData, field, Reflect.field (filter, field));
							
						}
						
						objectData.filters.push (filterData);
						
					}
					
				}
				
				objectData.id = object.id;
				
				if (object.matrix != null) {
					
					objectData.matrix = {};
					objectData.matrix.a = object.matrix.a;
					objectData.matrix.b = object.matrix.b;
					objectData.matrix.c = object.matrix.c;
					objectData.matrix.d = object.matrix.d;
					objectData.matrix.tx = object.matrix.tx;
					objectData.matrix.ty = object.matrix.ty;
					
				}
				
				objectData.name = object.name;
				
				frameData.objects.push (objectData);
				
			}
			
			data.frames.push (frameData);
			
		}
		
		return data;
		
	}
	
	
	private function resolveClass (name:String):Class <Dynamic> {
		
		var value = Type.resolveClass (name);
		
		if (value == null) {
			
			#if flash
			value = Type.resolveClass (StringTools.replace (name, "openfl._v2", "flash"));
			#else
			value = Type.resolveClass (StringTools.replace (name, "openfl._v2", "openfl"));
			#end
			
		}
		
		return value;
		
	}
	
	
}