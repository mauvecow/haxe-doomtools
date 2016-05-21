[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md)

Doomtools
=========

_A Haxe-based library for manipulating the data of id Software's game Doom (1993)_

Currently implemented:

 * WAD management - Loading, saving, manipulating lumps.
 * Map parsing - Reading and writing map data from the lumps.
 * Blockmap builder - With additional options to aggressively compress.
 * Node builder - Loosely based around ZenNode's, with re-entrant design.

Still left to do:

 * A reject builder - Currently makes a blank reject map.
 * Clients (CLI and web), preferably with hscript integration.
 * A set of tools for editing geometry dynamically.
 * Node builder: Linguortal support!
 * Node builder: Support for building GL nodes.
 * Node builder: Need to fix a generation bug on some complex maps; eg breach.wad.

This library is not quite ready for prime time so is not included in repositories yet.

Usage
=====

First install the latest version of [Haxe](http://www.haxe.org/download).

Currently, only source code is offered. Clone the repository with:

    git clone --recursive https://github.com/mauvecow/haxe-doomtools

Tell haxelib where you have installed the library:

    haxelib dev doomtools haxe-doomtools

And you're done! Just add the library to your project and you're good to go.

Haxe code can be compiled to any of the platforms listed on the Haxe site for easy integration.

Building the apps
=================

All you should need to do is send the hxml file to haxe, like so:

    haxe HXDoomNode.hxml

This is set to create the binary in the bin/ directory, ready for use.

Contact
=======

If you want to develop, feel free to leave an issue for me to talk it over with, or just be bold and throw a pull request. I may have different ideas for the direction, however.

If you'd like to talk, send an email to mauve@sandwich.net, though you'll probably get a more immediate response on [Twitter](https://twitter.com/mauvecow).
