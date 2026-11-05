package swf.exporters.animate;

class AnimateGeneratedTypeContext
{
	public static var currentBitmapLibrary(default, null):AnimateLibrary;
	public static var currentBitmapSymbol(default, null):AnimateBitmapSymbol;
	public static var currentButtonLibrary(default, null):AnimateLibrary;
	public static var currentButtonSymbol(default, null):AnimateButtonSymbol;
	public static var currentLibrary(default, null):AnimateLibrary;
	public static var currentSpriteSymbol(default, null):AnimateSpriteSymbol;

	public static function setBitmap(library:AnimateLibrary, symbol:AnimateBitmapSymbol):Void
	{
		currentBitmapLibrary = library;
		currentBitmapSymbol = symbol;
	}

	public static function clearBitmap():Void
	{
		currentBitmapLibrary = null;
		currentBitmapSymbol = null;
	}

	public static function clearBitmapIfMatches(library:AnimateLibrary, symbol:AnimateBitmapSymbol):Void
	{
		if (currentBitmapLibrary == library && currentBitmapSymbol == symbol)
		{
			clearBitmap();
		}
	}

	public static function consumeBitmap():AnimateGeneratedBitmapContext
	{
		if (currentBitmapLibrary == null || currentBitmapSymbol == null)
		{
			return null;
		}

		var context:AnimateGeneratedBitmapContext = {
			library: currentBitmapLibrary,
			symbol: currentBitmapSymbol
		};

		clearBitmap();
		return context;
	}

	public static function setButton(library:AnimateLibrary, symbol:AnimateButtonSymbol):Void
	{
		currentButtonLibrary = library;
		currentButtonSymbol = symbol;
	}

	public static function clearButton():Void
	{
		currentButtonLibrary = null;
		currentButtonSymbol = null;
	}

	public static function clearButtonIfMatches(library:AnimateLibrary, symbol:AnimateButtonSymbol):Void
	{
		if (currentButtonLibrary == library && currentButtonSymbol == symbol)
		{
			clearButton();
		}
	}

	public static function consumeButton():AnimateGeneratedButtonContext
	{
		if (currentButtonLibrary == null || currentButtonSymbol == null)
		{
			return null;
		}

		var context:AnimateGeneratedButtonContext = {
			library: currentButtonLibrary,
			symbol: currentButtonSymbol
		};

		clearButton();
		return context;
	}

	public static function setSprite(library:AnimateLibrary, symbol:AnimateSpriteSymbol):Void
	{
		currentLibrary = library;
		currentSpriteSymbol = symbol;
	}

	public static function clearSprite():Void
	{
		currentLibrary = null;
		currentSpriteSymbol = null;
	}

	public static function clearSpriteIfMatches(library:AnimateLibrary, symbol:AnimateSpriteSymbol):Void
	{
		if (currentLibrary == library && currentSpriteSymbol == symbol)
		{
			clearSprite();
		}
	}

	public static function consumeSprite():AnimateGeneratedSpriteContext
	{
		if (currentLibrary == null || currentSpriteSymbol == null)
		{
			return null;
		}

		var context:AnimateGeneratedSpriteContext = {
			library: currentLibrary,
			symbol: currentSpriteSymbol
		};

		clearSprite();
		return context;
	}
}

typedef AnimateGeneratedBitmapContext =
{
	var library:AnimateLibrary;
	var symbol:AnimateBitmapSymbol;
}

typedef AnimateGeneratedButtonContext =
{
	var library:AnimateLibrary;
	var symbol:AnimateButtonSymbol;
}

typedef AnimateGeneratedSpriteContext =
{
	var library:AnimateLibrary;
	var symbol:AnimateSpriteSymbol;
}
