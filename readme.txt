QUICK START GUIDE:
------------------

This CSS3 Font Converter is a shell script that allows developers, using a
command line, to convert a set of TTF and OTF fonts into all the other
currently used CSS3 @font-face formats (i.e. EOT, SVG, WOFF, WOFF2).  
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

FULL COMMAND LINE OPTIONS:
---------------------------

Usage: /Users/zhawry/bin/convertFonts.sh [-options] [fontfilelist]

Where: - [fontfilelist] is a space separated list of True Type (.ttf) or
         Open Type (.otf) fonts.
         
       - [-options] are one of the following:
       
         --use-font-weight: This option will merge all font-weights and 
         styles under the same font name.  This option will likely crash
         Apple Mobile Safari running under iOS versions less than 4.0.
         Also note that only the first four weights and styles
         will be recognized under IE7 and 8.
         
         --use-font-stretch: This option will merge all condensed and 
         expanded fonts under the same font name as the normal font.
         It is recommended *not* to use this method currently, since at
         the time of this writing, font-stretch is only supported by 
         Firefox => 9 and IE => 9.
         
         --autohint: This option will hint/re-hint fonts (using ttfautohint
         by default, or Adobe Font Development Kit for OpenType if using
         the --autohint=adobe option ). Note that this option will create
         a bunch of files prefixed with 'hinted-'.  Attempting to use this 
         option on files already prefixed with 'hinted-' will result in an 
         error.

      	 --use-font-prefix=xxx: This option will prepend the name of all the
      	 fonts with the string xxx.  This is useful when you are generating
      	 different stylesheets using the converter with the same font 
      	 but with different options.
      
      	 --output=xxx: This option will produce the resultant @font-face
         stylesheet to the file xxx. By default, xxx is set to stylesheet.css
         
         --show-features: Presents the user with a list of OpenType feature 
         tags a font supports which can be used inside a style sheet using 
         the CSS3 font-feature-settings property. The font can be in either 
         be OpenType or TrueType.
         
         --help: This help menu.

SUPPORTED OSes:
---------------

Windows (using Cygwin), OS X and Linux (tested on Ubuntu 10.10 Maverick
Meerkat).  Please let us know if you find it works on others.

This script should run on any version of UNIX running bash.
Installation instructions and more information can be found at
https://github.com/zoltan-dulac/css3FontConverter


REQUIREMENTS:
-------------

This script uses the following programs to do the heavy listing.
  - Fontforge:      http://fontforge.sourceforge.net/
  - ttf2eot:        http://code.google.com/p/ttf2eot/)
  - sfnt2woff:      http://people.mozilla.com/~jkew/woff/
  - ttfautohint:    http://www.freetype.org/ttfautohint/
  - woff2_compress: http://code.google.com/p/font-compression-reference/w/list
  - EOTFAST:        http://eotfast.com/ (Windows only, included in this package
                    with kind permission from Richard Fink 
                    (http://readableweb.com/)
  
Full instructions on how to install these packages are at:

http://www.useragentman.com/blog/the-css3-font-converter/

LICENSE:
--------

This code is released under the LGPL.  License can be found at http://www.gnu.org/licenses/lgpl.html

CHANGELOG:
----------

Feb 20, 2011 - Initial Release
Sep 22, 2013 - Added support for font-weight and autohinting, as well as
               reporting what font-feature-support tags (i.e. OpenType feature
               tags) are implemented by a font.
Sep 02, 2014 - Added support for WOFF2 fonts, if woff2_compress is in the user's
               path.  This program can be retrieved from here:
               http://code.google.com/p/font-compression-reference/w/list
CONTACT:
--------

Any bug reports, fixes or feature requests: zoltan.dulac@gmail.com.  
Code available at https://github.com/zoltan-dulac/css3FontConverter
