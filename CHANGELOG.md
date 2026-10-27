3.5.0 (10/27/2026)
------------------

* Added `DisplayObject.metaData` support for Animate libraries
* Added `lineGradientStyle` support for SWF shapes in Animate, SWFLite and runtime shapes
* Added caching of generated classes for Flash and AIR SWF libraries
* Added export of linked MP3 and uncompressed sounds in Animate libraries (MP3 on native targets requires Lime 8.4 or newer)
* Added the `swf_compact_animate_timelines` define, to keep Animate timelines in compact buffers instead of one object per frame and event
* Added the `swf_hardware_bitmap_cache` define, to share Animate bitmaps and release their CPU images once uploaded
* Improved `generate="true"` on Animate libraries to compile the generated classes, so symbols are created as their linkage class
* Improved Animate shape memory usage by keeping commands compact until a shape is first drawn
* Improved SWF exporter performance for shapes with many drawing commands
* Improved timeline performance by caching instance field lists per class
* Improved dynamic text performance by caching the embedded font found for each symbol
* Changed `AnimateShapeSymbol.commands` to be `null` for shapes loaded from an Animate library
* Changed `ShapeCommand` and `AnimateShapeCommand` to include `LineGradientStyle`, so exhaustive `switch` statements over them need another case
* Changed haxelib.json to declare the `format` dependency
* Fixed Animate and SWFLite exports of SWF files without ABC or `SymbolClass` tags, such as AS2 SWF files using `ExportAssets`
* Fixed `SWFLibrary` failing to load non-embedded SWF files
* Fixed processing SWF files with linked Speex sounds
* Fixed generated Animate classes using another library's symbol when several libraries export the same class
* Fixed generated Animate classes not being used, or extending the wrong base class, when the library has a `prefix`
* Fixed the document class not being applied to the root timeline when it is not named `*_fla.MainTimeline`
* Fixed clipping characters being displayed when nothing is in their mask range
* Fixed reused timeline instances keeping an outdated `clipDepth`
* Fixed Animate `blendMode` being set to the string `"null"`
* Fixed `clippingLayer` being set on the Flash target
* Fixed SWFLite timelines failing to compile on the Flash target
* Fixed `DefineFont2` and `DefineFont3` parsing reading past the tag for fonts without layout
* Fixed `SWFRoot.publish()` sizing bit fields from the decimal digits of each value, which wrote broken matrices, rectangles, color transforms and shapes
* Fixed generated Flash/AIR classes being written to the wrong package directory
* Fixed C++ compile error in `AnimateLibraryExporter` class generation
* Fixed Animate libraries created without a UUID being registered under a `null` key
* Fixed processed Animate ZIP files not being closed after writing
* Fixed the command-line tools showing the version of Lime instead of swf


3.4.0 (11/11/2025)
------------------

* Added `BevelFilter` and `ConvolutionFilter` support
* Fixed duplicate `scale9Grid` graphics
* Fixed clipping layers in OpenFL 9.5 and newer, since masks cannot be shared
* Fixed some filter imports on Flash target
* Fixed wrong minimum and maximum integer values used for certain comparisons
* Fixed string formatting conversion from ActionScript to Haxe
* Fixed `swf.runtime.MovieClip` exception when setting field that does not exist on some targets

3.3.1 (10/22/2024)
------------------

* Fixed run script


3.3.0 (10/22/2024)
------------------

* Added `SymbolUtils` utility class to reduce duplicate code
* Added Implementation for `IDisplayObjectLoader`
* Improved garbage collection performance
* Fixed `haxelib run swf process` with a single argument
* Fixed memory leak
* Fixed crash when `Sprite` is cast as a `Shape`
* Fixed ndll loader path for arm64 Mac


3.2.0 (10/27/2022)
------------------

* Added `AnimateLibrary.loadFromFile` for processed ZIP files
* Added `AnimateLibrary.loadFromBytes` and `AnimateLibrary.loadFromBundle`
* Added `haxelib run swf generate` to generate SWF classes
* Improved `haxelib run swf process` to support directories and files
* Improved `haxelib run swf` as a standalone tool for SWF pre-processing
* Improved log output for better feedback
* Fixed blend mode support in Animate libraries
* Fixed support for `Assets.list` and `AssetType.MOVIE_CLIP`


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
