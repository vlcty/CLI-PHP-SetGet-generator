CLI PHP SetGet generator
========================

A CLI tool to generate setter and getter methods based on existing members and their data types

The idead behind
================

I use Sublime Text 3 for developing in script languages like PHP. I came from the Java/C# world and had powerfull IDEs like Eclipse and Visual Studio which took away the work of writing setters and getters for member variables.
Sublime does not have such a feature. So I developed my own little application to do this. I recently refactored it completely and added a PHPDoc switch. Not it's time to make it available to the public.

The application reads the PHP file and filters out the member variables with their scope (private or protected), the name and the data type. Afterwards the output is written to ``STDOUT``

Calling the application
=======================

``cd`` into the directory where the ``generator.pl`` file is.

Call it with perl and the option ``--sourcefile`` and the path to the PHP class source file.
For example with the ``TestClass.php`` file:

``perl distributor.pl --sourcefile "TestClass.php"``

You can also generate some basic PHPDoc code:

``perl distributor.pl --sourcefile "TestClass.php" --phpdoc``

*Note*: A full qualified path to the file can come in very handy. Multiple files are not supported and I won't implement it because I think it's an unnecessary feature.

**Pro Tipp:**

If you don't want to copy long output from the command line there is a simple trick on linux with X11 display servers:
You can pipe the output to ``xclip``. This is a tool to get text into the clipboard.  
*Note:* The output is not in the PRIMARY-Clipboard (``Ctrl + C, CTRL + V``) but in the SECONDARY-Clipboard (for me I have to press the mouse wheel down).

After piping it into ``xclip`` go into your editor and press the mouse wheel down or your corresponding key. Example:

``perl distributor.pl --sourcefile "TestClass.php" --phpdoc | xclip``

You can install xclip via your package manager.

Command line options
====================

You can call some options on it. Required is the ``--sourcefile`` option.

- ``--sourcefile`` -> Path to the PGP class source file
- ``--help`` -> Print a help message with licence information
- ``--phpdoc`` -> Generate (simple) PHPDoc for easy fill-out the rest

Supported data types
========================

Currently the application unserstands the following data types:

- strings
- integers
- floats
- objects
- arrays
- boolean

Dependencies
============

It's written in perl so a running perl environment would be nice :-D
The application itself just needs ``Getopt::Long`` which is mostly installed. If not use CPAN or google it :-D