package format.swf.lite.symbols;


import haxe.Json;


class SWFSymbol {
	
	
	public var className:String;
	public var id:Int;
	
	private var type:String;
	
	
	public function new () {
		
		type = "";
		
	}
	
	
	public function parse (data:Dynamic):Void {
		
		className = data.className;
		id = data.id;
		
	}
	
	
	public function prepare ():Dynamic {
		
		return this;
		
	}
	
	
	public static function unserialize (data:Dynamic):SWFSymbol {
		
		var symbol:SWFSymbol = switch (data.type) {
			
			case "bitmap": new BitmapSymbol ();
			case "dynamictext": new DynamicTextSymbol ();
			case "font": new FontSymbol ();
			case "shape": new ShapeSymbol ();
			case "sprite": new SpriteSymbol ();
			case "statictext": new StaticTextSymbol ();
			case "text": new TextSymbol ();
			default: new SWFSymbol ();
			
		}
		
		symbol.parse (data);
		return symbol;
		
	}
	
	
}