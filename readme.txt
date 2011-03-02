SUMMARY
-------

This CSS3 Font Converter is a shell script that allows developers, using a
command line, to convert a set of TTF and OTF fonts into all the other
currently used CSS3 @font-face formats (i.e. EOT, SVG, WOFF).  
Syntax:

    convertFonts.sh <filelist>

For example, if you wanted to convert all the .ttf files in the directory
you are in, you could type in the command:

    $ convertFonts.sh *.ttf

The fonts will then be converted to the .eot, .woff, and .svg formats.  It
will also generate a stylesheet, stylesheet.css, that will produce the
@font-face rules using The New Bulletproof @Font-Face Syntax.  

If you are converting .otf fonts, a .ttf font will be generated first before
the other fonts. 

SUPPORTED OSes:
---------------

Windows (using Cygwin), OS X and Linux (tested on Ubuntu 10.10 Maverick
Meerkat).  Please let us know if you find it works on others.

REQUIREMENTS:
-------------

The shell script that uses FontForge, Batik (with Java installed), sfnt2woff
and either EOTFast or ttf2eot. Full instructions on how to install these
packages are at:

http://www.useragentman.com/blog/2011/02/20/converting-font-face-fonts-quickly-in-any-os/

CONTACT:
--------

Any bug reports, fixes or feature requests: zoltan.dulac@gmail.com.  
Code available at https://github.com/zoltan-dulac/css3FontConverter
