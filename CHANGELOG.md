3.1.1 (09/12/2022)
------------------

* Fixed "Invalid field access : length" error

3.1.0 (08/31/2022)
------------------

* Added support for OpenFL 9.2 `@:bind` to extend SWF symbol classes
* Added support to extend `Sprite` classes (in addition to `MovieClip`)
* Added initial support for SWC files
* Added support for multiple labels per frame in Animate libraries
* Improved `MovieClip` animation performance in Animate libraries
* Improved class generation to allow `generate="false"` to disable
* Fixed initialization order to allow extending generating classes
* Fixed support for `Assets.exists` without specifying asset type
* Fixed `Std.is` deprecation warnings


3.0.2 (09/16/2020)
------------------

* Remove `implements Dynamic` on MovieClip template for Haxe 4 support


3.0.1 (09/14/2020)
------------------

* Fixed support for scale9Grid in the Animate timeline
* Fixed warnings while compiling using Animate timeline and the HTML5 target
* Fixed a compilation issue when generating classes and targeting Flash


3.0.0 (08/14/2020)
------------------

* Initial release using Timeline API (OpenFL >= 9)