package format.swf.lite;


import format.swf.lite.symbols.ButtonSymbol;


class SimpleButton extends flash.display.SimpleButton {
	
	
	@:noCompletion private var symbol:ButtonSymbol;
	
	
	public function new (swf:SWFLite, symbol:ButtonSymbol) {
		
		super ();
		
		this.symbol = symbol;
		
		downState = new MovieClip (swf, symbol.downState);
		hitTestState = new MovieClip (swf, symbol.hitState);
		overState = new MovieClip (swf, symbol.overState);
		upState = new MovieClip (swf, symbol.upState);
		
	}
	
	
}