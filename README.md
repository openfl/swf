[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md) [![Haxelib Version](https://img.shields.io/github/tag/openfl/swf.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/swf)

SWF
===

Provides SWF parsing and rendering for C++, Flash and HTML5


Usage
=====

First, make sure that `<haxelib name="swf" />` has been added to your project.

Then, you can add `<library path="to/your.swf" preload="true" />` to include a SWF library. This will be available at runtime using the file name of the SWF (minus the ".swf") or you can add 'id="my-unique-id"' to specify a custom name.

There is a (beta) option for 'generate="true"' to generate Haxe classes for each "Export for ActionScript" type in the SWF file. The 'preload' is also optional, but is recommended to simplify use.

You can create an "Export for ActionScript" clip from a SWF like this:

    var clip = Assets.getMovieClip ("my-swf:MyMovieClipName");

If you would prefer to create the whole timeline, use an empty clip name:

    var timeline = Assets.getMovieClip ("my-swf:");

If you use the 'generate' option, you would instead create a new instance like this:

    var clip = new MyMovieClipName ();


Installation
============

You can easily install SWF using haxelib:

    haxelib install swf

To add it to a Lime or OpenFL project, add this to your project file:

    <haxelib name="swf" />


Development Builds
==================

Clone the SWF repository:

    git clone https://github.com/openfl/swf

Tell haxelib where your development copy of SWF is installed:

    haxelib dev swf swf

Go to the cloned folder:

    cd swf

Tell haxe to build the tools:

    haxe rebuild.hxml

To return to release builds:

    haxelib dev swf
