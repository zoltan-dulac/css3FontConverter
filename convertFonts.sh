#!/bin/bash

#########################################################################
# CSS3 @font-face Converter v2.1
# by Zoltan Hawryluk (http://www.useragentman.com)
# More info available at http://useragentman.com/blog/8QtbI
#########################################################################

#########################################################################
## CONFIGURATION AREA: This stuff is the only stuff you may need to     #
##                     change.                                          #
#########################################################################

# The path should contain the directories where EOTFAST-1.EXE, ttf2eot,
# fontforge, ttfautohint and all the scripts in the @Font-Face Contruction Set reside.
# Uncomment the line below with the right directories.  Remember the 
# $PATH at the beginning of the string, or the script will forget what
# was originally in the PATH.
#PATH="$PATH:/paths/to/other/dependencies/go/here"


#########################################################################
# OPTIONS                                                               #
#########################################################################
ARGS=`echo $* | tr ' ' '
'`

SHOW_FEATURES=`echo "$ARGS" | grep '\--show-features'`
USE_FONT_WEIGHT=`echo "$ARGS" | grep '\--use-font-weight'`
USE_FONT_STRETCH=`echo "$ARGS" | grep '\--use-font-stretch'` 
DO_AUTOHINT=`echo "$ARGS" | grep '\--autohint'`
OUTPUT=`echo "$ARGS" | grep '\--output'`
USE_FONT_PREFIX=`echo "$ARGS" | grep '\--use-font-prefix'`
USE_TTF2EOT=`echo "$ARGS" | grep '\--use-ttf2eot'`


CLEANUP=`echo "$ARGS" | grep '\--clean'` 
 
SHOW_HELP=`echo "$ARGS" | grep '\--help'`

OPTIONS=`echo "$ARGS" | grep '\--' | tr '
' ' '`

ARGS=`echo "$ARGS" | grep -v '\--'`

STYLESHEETFILE=`echo $OUTPUT | awk -F'=' '{print $2}'`
if [ "$STYLESHEETFILE" = "" ]
then
  STYLESHEETFILE='stylesheet.css'
fi

FONT_PREFIX="`echo $USE_FONT_PREFIX | awk -F'=' '{print $2}'`"

#.. is 0 if has this binary, non-zero otherwise 
HAS_WOFF2_COMPRESS=`which 'woff2_compress' > /dev/null; echo $?`

if [ "$FONT_PREFIX" = "" -a "$DO_AUTOHINT" != "" ] 
then
	FONT_PREFIX="hinted-"
fi


#.. Before we do anything else -- make sure the args are all real files.  If one
#   of them isn't, bail, since we don't want the output to be something 
#   unexpected and BAD.


if [ "$ARGS" = "" -a "$CLEANUP" = "" -a "$SHOW_HELP" = "" ]
then
	echo
	echo "No arguments.  Bailing."
	echo
	echo "Try '$0 --help' for instructions."
	echo
	exit 30
fi

for i in $ARGS
do
	if [ ! -f $i ]
	then
		echo "One of the files you want to convert ($i) is not
a file.  Bailing." 1>&2
  	exit 40
	fi
done

if [ "$DO_AUTOHINT" != "" ]
then

	AUTOHINTER="`echo $DO_AUTOHINT | awk -F'=' '{print $2}'`"

	if [ "$AUTOHINTER" = "" ]
	then
		AUTOHINTER="ttfautohint"
	elif [ "$AUTOHINTER" = "adobe" ]
	then
		AUTOHINTER="autohint"
	elif [ "$AUTOHINTER" != "ttfautohint" ]
	then
		echo "The autohint option must be set to either ttfautohint or adobe. Bailing" 1>&2
		exit 30 
	fi
fi

if [ "$HAS_WOFF2_COMPRESS" != "0" ]
then
	echo "

**********************************************************************************
*
* NOTE: You either don't have woff2_compress installed on your machine
* or it is not in your path.  If you want WOFF2 support, please install this
* application.  Details on doing this available at:
* 
* http://code.google.com/p/font-compression-reference/w/list
*
* (Click on the "gathering_compression_improvement_numbers" link).
*
* Not having WOFF2 support is not a show stopper, so we will continue converting 
* your fonts, but you can save 30-50% on a font download with browsers that do
* support it, so it is highly recommended.
*
**********************************************************************************

"
fi 

#########################################################################
## PROGRAM AREA                                                         #
#########################################################################

#.. check for fontforge
FONTFORGE_EXT=""
FONTFORGE=`which fontforge 2> /dev/null`
if [ "$?" != "0" ]
then 
	FONTFORGE_EXT="bat"
	FONTFORGE=`which fontforge.bat 2> /dev/null`
	
	if [ "$?" != "0" ]
	then
		echo "Error: FontForge is not installed. Bailing" 1>&2
		exit 5
	fi
fi


FILE_STUBS=''
SCRIPT_DIR=`echo $0 | sed "s/convertFonts.sh//"`

IFS=$(echo -en "\n\b")


if [ "$SHOW_HELP" != "" ]
then
  echo "
CSS3 Font Converter by Zoltan Hawryluk.
Released under the MIT Public Licence, 2011-2013.

Usage: $0 [-options] [fontfilelist]

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
      	 fonts with the string "xxx".  This is useful when you are generating
      	 different stylesheets using the converter with the same font 
      	 but with different options.
      
      	 --output=xxx: This option will produce the resultant @font-face
         stylesheet to the file xxx. By default, xxx is set to stylesheet.css
         
         --show-features: Presents the user with a list of OpenType feature 
         tags a font supports which can be used inside a style sheet using 
         the CSS3 font-feature-settings property. The font can be in either 
         be OpenType or TrueType.
         
         --help: This help menu.
         
This script uses the following programs to do the heavy listing.
  - Fontforge:      http://fontforge.sourceforge.net/
  - EOTFAST:        http://eotfast.com/
  - ttf2eot:        http://code.google.com/p/ttf2eot/)
  - sfnt2woff:      http://people.mozilla.com/~jkew/woff/
  - ttfautohint:    http://www.freetype.org/ttfautohint/
  - woff2_compress: http://code.google.com/p/font-compression-reference/w/list
  
This script can run on any version of UNIX running bash, and is
designed to also run under Windows using Cygwin. Installation instructions 
and more information can be found at
https://github.com/zoltan-dulac/css3FontConverter
         
"
  exit 1

#.. if --show-features is set, then we just open the font file and show what
#   font feautres are supported by the font
elif [ "$SHOW_FEATURES" != "" ]
then
  for i in $ARGS
  do
		echo
		echo "Font: $i"
		# echo -n "Vendor: "
		# $FONTFORGE -script 'showVendor.pe'
		$FONTFORGE -script $SCRIPT_DIR/tableSupport.pe $i 2> /dev/null | 
			sed "s/\[//g; s/\]//g;" | tr ',' '
'
		
  done
  
  echo 
	echo "Information on these features can be found at these URLS: "
	echo "  - http://www.microsoft.com/typography/otspec/featurelist.htm"
	echo "  - http://partners.adobe.com/public/developer/opentype/index_tag3.html"
	echo
	exit 0

		

#.. if the clean option is set, let's get rid of all files this
#   script may have created.
elif [ "$CLEANUP" != "" ]
then

  echo "
WARNING!  This will remove all non TTF and OTF fonts,
as well as hinted fonts and css stylesheets, in this directory.
Are you *sure* you want to do this [y/N]?"
  read ANS
  
  if [ "$ANS" = "y" -o "$ANS" = "Y" ]
  then
    echo "Removing files."
    rm -r *.eot *.svg *.woff *.woff2  old *.css hinted-*.ttf 2> /dev/null
    
   
    
    echo "DONE"
    exit 20
  else 
    exit 21
  fi 


#.. if the filelist contains any files prefixed with 'hinted-' and the 
#   --autohint option is set, give an error and exit immediately.
elif [ "$DO_AUTOHINT" != "" ]
then
  HINTED_FILES=`echo "$ARGS" | egrep "^hinted-"`
  
  if [ "$HINTED_FILES" != "" ]
  then
    echo "ERROR: Attempting to autohint already hinted files. You 
should only try to autohint files that haven't been hinted already.
You should try to clean this directory by running this script with
the --clean option.  See --help for more details.  Bailing. " 1>&2
    exit 10
  fi
 

fi 




#.. converts a font to TTF
toTTF () {
	if [ "$FONTFORGE_EXT" = "bat" ]
	then
		echo "(Using MingW FontForge)"
		$FONTFORGE -script `cygpath -w $SCRIPT_DIR/2ttf.pe` \
			`cygpath -w $i` 2> /dev/null
	else
		echo "(Using Cygwin or Unix FontForge)"
		$FONTFORGE -script $SCRIPT_DIR/2ttf.pe $i 
	fi
	
}

#.. converts a font to EOT format.  Uses EOTFAST if possible, fallbacks
#   to TTF2EOT otherwise.  Note that that TTF2EOT is used if EOTFAST is
#   not installed, or if EOTFAST fails (which sometimes happens).

toEOT () {
	which 'EOTFAST-1' > /dev/null
	FOUND="$?"
	
		
	if [ "$FOUND" = "0" -a  "$USE_TTF2EOT" =	"" ]
	then
		echo "(Using EOTFAST)"
		EOTFAST-1 $1 $FILE_STUB.eot
		SUCCESS="$?"
	
		if [ "$SUCCESS" != "0" ]
		then
			echo "EOTFAST failed.  Using ttf2eot instead"
		fi
	fi
	
	
	if [ "$FOUND" != "0" -o "$SUCCESS" != "0" -o "$USE_TTF2EOT" != "" ]
	then
		echo "(Using ttf2eot)"
		FILE_STUB=`echo $NEW_FILE |
			sed "s/\.[tT][tT][fF]$//" |
			sed "s/\.[oO][tT][fF]$//"`
		ttf2eot $1 > $FILE_STUB.eot
	fi
}

#.. converts a font to SVG.  Perhaps we should remove the BATIK
#   dependency.
toSVG() {
	if [ -f $SCRIPT_DIR/2svg.pe ]
	then
		fontforge -script $SCRIPT_DIR/2svg.pe $1 2> /dev/null
	else 
		echo "Error: cannot produce SVG font"
	fi
}

#.. This gets the font name.  Used when not using the 
#   --use-font-weight option.
getFontName () { 

  
	if [ "$FONTFORGE_EXT" = "bat" ]
	then
		$FONTFORGE -script `cygpath -w $SCRIPT_DIR/getFontName.pe` \
			`cygpath $1` 2> /dev/null | tr ' ' '_'  |
			sed "s/
//g" 
	else
		fontforge -script $SCRIPT_DIR/getFontName.pe $1 2> /dev/null | tr ' ' '_' 
	fi
}





getSVGID () {
	grep "id=" $1 | tr ' ' '
' | grep ^id | awk -F'"' '{print $2}'
}

toWOFF () {
	sfnt2woff $1
}

toWOFF2 () {
	if [ "$HAS_WOFF2_COMPRESS" = "0" ]
	then
		woff2_compress $1
	fi
}

#.. This sets some (ugh) global variables with information about a font from
#   fontforge.
getFontInfo() {
	OUT=`fontforge -script $SCRIPT_DIR/getFontInfo.pe $1 2> /dev/null`
	
	INFO_WEIGHT=`echo "$OUT" | egrep "^Weight:"` 
	INFO_FONTNAME=`echo "$OUT" | egrep "^Font name:"`
	INFO_FULLNAME=`echo "$OUT" | egrep "^Full name:"`
	INFO_ITALICANGLE=`echo "$OUT" | egrep "^Italic angle:"`
}

#.. isWeightStyle() takes one parameter that can be one of the following:
#      
#     Bold, Italic, Condensed, Narrow
#
#   the function will return T if it is of the type passed, F otherwise.

isWeightStyle () {
	STYLE=`echo $1 | sed 's/ /\[ _-\]/g'`
	R="F" 
	
	echo "$INFO_WEIGHT" | grep -i "$STYLE" > /dev/null
	
	if [ "$?" = "0" ]
	then
		R="T"
		else
		echo "$INFO_FULLNAME" | grep -i "$STYLE" > /dev/null
		if [ "$?" = "0" ]
		then
			R="T"
		else 
	
			echo "$INFO_FONTNAME" | grep -i "$STYLE" > /dev/null
	
			if [ "$?" = "0" ]
			then
				R="T"
			fi
		fi
	fi

	#.. if we are testing for italic and the answer is F so far, check the 
	#   italic angle
	if [ "$R" = "F" -a "$STYLE" = "italic" ]
	then
		ANGLE=`echo "$INFO_ITALICANGLE" | awk -F": " '{print $2}'`
		
		if [ "$ANGLE" != "0" ]
		then
			R="T"
		fi
	fi
	echo $R
}

#.. doautohint() -- takes 1 parameter ($1) which is file that is to be hinted.
#   This function will write the hinted font to the same file name with the
#   prefix '$FONT_PREFIX'.  

doautohint() {

	if [ "$AUTOHINTER" = "ttfautohint" ]
	then
		#
		# These are the best options after fiddling around with this a lot.
		# Note that as of 0.96, the option "--components" has been replaced 
		# by "--composites". 
		# http://sourceforge.net/projects/freetype/files/ttfautohint/0.96/
		# 
		# Thanks to github user "pep-" for pointing this out.
		#

		if [ "$TTFAUTOHINT_096_HIGHER" = "T" ] 
		then 
			COMP='--composites'
		else 
			COMP='--components'
		fi

		ttfautohint  --strong-stem-width="" --windows-compatibility $COMP $1 $FONT_PREFIX$1
	else
		#.. The adobe autohinter spews out a lot of junk.  For now, hide it.
		autohint -q -o $FONT_PREFIX$1 $1 2> /dev/null | grep -iv error | grep -v "^." | grep -v "^$"
	fi 
}



if [ "$#" -eq "0" ]
then
	echo "Usage: $0 <font list>" 1>&2
	exit 1
fi

# .. check to make sure all packages are installed
for i in sfnt2woff java 
do
	which "$i" > /dev/null 2> /dev/null
	if [ "$?" != "0" ]
	then
		echo "Error: Package $i is not installed.  Bailing" 1>&2
		exit 2
	fi
done

# .. check for ttfautohint is installed if --autohint option is set
if [ "$DO_AUTOHINT" != "" ]
then
	which $AUTOHINTER > /dev/null 2> /dev/null
	if [ "$?" != "0" ]
	then
		echo "Error: Package $AUTOHINTER is not installed. You cannot use the 
	--autohint=$AUTOHINTER option without it.  Bailing.
	" 1>&2
		exit 2
	else
		#.. We will now check for the version.
		TTFAUTOHINT_096_HIGHER=`ttfautohint --version |
			grep ttfautohint | 
			awk '{if ($2 >= 0.96) { 
				print "T" 
			} else { 
				print "F"
			} 
			}'`
		
		echo -n "Using version of ttfautohint >=0.96? "
		echo $TTFAUTOHINT_096_HIGHER
	fi
fi 

	


#.. checks for binaries that convert to EOT format.
HAS_EOT_SUPPORT=1
for i in EOTFAST-1 ttf2eot 
do
	which "$i" > /dev/null 2> /dev/null
	HAS_EOT_SUPPORT=`expr $? \* $HAS_EOT_SUPPORT`
done

if [ "$HAS_EOT_SUPPORT" = "1" ]
then
	echo "Error: EOTFAST and/or ttf2eot is not installed. Bailing." 1>&2
	exit 4
fi

if [ -d old ]
then
	mkdir old
fi

#.. for each font, we create an @font-face rule.
for i in $ARGS
do
	
	#.. check to see if it's a TrueType font
	file "$i" | grep "TrueType" > /dev/null
	IS_TTF="$?"

	file "$i" | grep "Spline Font Database" > /dev/null
	IS_SFD="$?"
	
	file "$i" | grep "OpenType" > /dev/null
	IS_OTF="$?"

	if [ "$IS_OTF" = "0" ]
	then
		ORIG_TYPE="otf"
		
	elif [ "$IS_TTF" = "0" ]
	then
		ORIG_TYPE="ttf"
	fi
	
	if [ "$DO_AUTOHINT" != "" -a \
			\( \( "$ORIG_TYPE" = "ttf" -a "$AUTOHINTER" = "autohint" \) -o \
			\( "$ORIG_TYPE" = "otf" -a "$AUTOHINTER" = "ttfautohint" \) \) ]
		then
			echo "Error!  Cannot use $AUTOHINTER on $ORIG_TYPE fonts.  Bailing" 1>&2
			exit 30
		fi
	
	

	if [ "$IS_OTF" = 0 -o "$IS_TTF" = 0 -o "$IS_SFD" = 0 ]
	then
		cp $i old
	
		NEW_FILE=`echo $i | sed "s/ /_/g; s/TTF$/ttf/; s/OTF$/otf/"`

		if [ "$i" != "$NEW_FILE" ]
		then
			echo "Removing spaces in font name."
			mv $i $NEW_FILE
			i="$NEW_FILE"
		fi
	
		FILE_STUB=`echo $NEW_FILE | 
			sed "s/\.[tT][tT][fF]$//" |
			sed "s/\.[oO][tT][fF]$//"`

		# echo $FILE_STUB

		#.. If this is an OTF Font, then convert it to TTF.  

		if [ "$IS_OTF" = "0" ]
		then 
		
			if [ ! -f $FILE_STUB.ttf ]
			then
				toTTF $NEW_FILE
			fi
			NEW_FILE="$FILE_STUB.ttf"
		fi
		
		
		#.. If --autohint option is set, we must hint
		#   this file with ttfautohint
		if [ "$DO_AUTOHINT" != "" ]
		then
		
			echo "Hinting $NEW_FILE ..."
			doautohint $NEW_FILE
			FILE_STUB="$FONT_PREFIX$FILE_STUB"
			NEW_FILE="$FONT_PREFIX$NEW_FILE"
		fi
		
		

		if [ ! -f $FILE_STUB.eot ]
		then
			echo "Converting $FILE_STUB to eot ($NEW_FILE)"
			toEOT $NEW_FILE 
		else 
			echo "$FILE_STUB.eot exists, skipping ..."
		fi
	
		#.. do not convert a font to svg format if we are using
		#   --use-font-weight, since several SVG declarations of
		#   the same font will not work in iOS < 4.2.
		if [ "$USE_FONT_WEIGHT" = "" ]
		then
		
			if [ ! -f $FILE_STUB.svg ]
			then
				echo "Converting $FILE_STUB to svg"
				toSVG $NEW_FILE $FILE_STUB
			else 
				echo "$FILE_STUB.svg exists, skipping ..."
			fi
			
	fi
	
		if [ ! -f $FILE_STUB.woff ]
		then
			# NOTE: we use $i instead of $NEW_FILE, since woff is
			# just a wrapper for OTF and TTF.  Having the original
			# OTF is better here, unless we are autohinting.
			if [ "$DO_AUTOHINT" != "" ]
			then
				echo "Converting $FILE_STUB to woff from converted TTF"
				toWOFF $NEW_FILE
			else
				echo "Converting $FILE_STUB to woff from original font $i."
				toWOFF $i
			fi
		else 
			echo "$FILE_STUB.woff exists, skipping ..."
		fi
				
		if [ ! -f $FILE_STUB.woff2 -a "$HAS_WOFF2_COMPRESS" == "0" ]
		then
			# NOTE: we use $i instead of $NEW_FILE, since woff2 is
			# just a wrapper for OTF and TTF.  Having the original
			# OTF is better here, unless we are autohinting.
			if [ "$DO_AUTOHINT" = "" ]
			then
				echo "Converting $FILE_STUB to woff2 from original font $i."
				toWOFF2 $i
			fi

			if [ "$?" != "0" -o "$DO_AUTOHINT" != "" ]
			then
				echo "Converting $FILE_STUB to woff2 from converted TTF ($NEW_FILE)"
				toWOFF2 $NEW_FILE
			fi
		else 
			echo "$FILE_STUB.woff2 exists, skipping ..."
		fi

	
		FILE_STUBS="$FILE_STUBS $FILE_STUB"
	else 
		echo "File $i is not a TrueType or OpenType font. Skipping"
	fi
done


echo "Writing Stylesheet ..."

COMMENT=\
"/*
 * This stylesheet generated by the CSS3 @font-face generator v2.0
 * by Zoltan Hawryluk (http://www.useragentman.com). 
 * Latest version of this program is available at
 * https://github.com/zoltan-dulac/css3FontConverter"
 
if [ "$OPTIONS" != "" ]
then
  COMMENT="$COMMENT
 *
 * Generated with the following options:
 * 
 * $OPTIONS"
fi

COMMENT="$COMMENT
 */
" 

echo "$COMMENT" > $STYLESHEETFILE

IFS=$(echo -en " ")

for i in $FILE_STUBS
do

	
	if [ "$USE_FONT_WEIGHT" != "" ]
	then
		#.. first, get the info about the font from fontforge.
		getFontInfo $i
		
		#.. next, from the fontforge info, find out if the font is bold, italic and/or condensed.
		IS_BOLD=`isWeightStyle 'bold'`
		IS_BLACK=`isWeightStyle 'black'`
		IS_LIGHT=`isWeightStyle 'light'`
		IS_MEDIUM=`isWeightStyle 'medium'`
		IS_THIN=`isWeightStyle 'thin'`
		IS_EXTRA_LIGHT=`isWeightStyle 'extra light'`
		IS_DEMI_BOLD=`isWeightStyle 'demi bold'`
		IS_EXTRA_BOLD=`isWeightStyle 'extra bold'`
		
		IS_ITALIC=`isWeightStyle 'italic'`
		
		IS_CONDENSED=`isWeightStyle 'condensed'`
		IS_EXPANDED=`isWeightStyle 'expanded'`
		
		#.. condensed and narrow are the same (I believe).
		if [ "$IS_CONDENSED" = "F" ]
		then
			IS_CONDENSED=`isWeightStyle 'narrow'`
		fi
		
		#.. set variables that will be used in the @font-face declaration
		#   These values were grabbed from the article at
		#   http://destination-code.blogspot.ca/2009/01/font-weight-number-keywords-100-900.html
		if [ "$IS_THIN" = "T" ]
		then
			FONT_WEIGHT="100";
		elif [ "$IS_EXTRA_LIGHT" = "T" ]
		then
			FONT_WEIGHT="200";
		elif [ "$IS_LIGHT" = "T" ]
		then
			FONT_WEIGHT="300";
		elif [ "$IS_BOLD" = "T" ]
		then
			FONT_WEIGHT="700";
		elif [ "$IS_MEDIUM" = "T" ]
		then
			FONT_WEIGHT="500";
		elif [ "$IS_DEMI_BOLD" = "T" ]
		then
			FONT_WEIGHT="600";
		elif [ "$IS_EXTRA_BOLD" = "T" ]
		then
			FONT_WEIGHT="800";
		
		elif [ "$IS_BLACK" = "T" ]
		then
			FONT_WEIGHT="900"
		else
			FONT_WEIGHT="400";
		fi
		
		if [ "$IS_ITALIC" = "T" ]
		then
			FONT_STYLE="italic";
		else
			FONT_STYLE="normal";
		fi
		
		if [ "$USE_FONT_STRETCH" != "" ]
		then
			if [ "$IS_CONDENSED" = "T" ]
			then
			  FONT_STRETCH="condensed";
			elif [ "$IS_EXPANDED" = "T" ]
			then
			  FONT_STRETCH="expanded";
			else
			  FONT_STRETCH="normal";
			fi
		fi
		
		
		#.. the name we will refer to in CSS will be without the words "Bold", "Italic", etc.
		#   NOTE: I Wanted to use sed with the 'gi' options, but OSX's sed (BSD
		#	I assume) doesn't do the 'i' case insensitive switch. Boo!
		FONTNAME_SED_OPTIONS="s/[bB][oO][lL][dD]//g;
			s/[iI][tT][aA][lL][iI][cC]//g;
			s/[lL][iI][gG][hH][tT]//g;
			s/[rR][eE][gG][uU][lL][aA][rR]//g;
			s/[mM][eE][dD][iI][uU][mM]//g;
			s/[lL][iI][gG][hH][tT]//g;
			s/[bB][lL][aA][cC][kK]//g;
			s/[eE][xX][tT][rR][aA]//g;
			s/[dD][eE][mM][iI]//g;
			s/[rR][oO][mM][aA][nN]//g;
			s/[tT][hH][iI][nN]//g;"
		
		#.. we also remove the words "Condensed" and "Expanded" if the --use-font-stretch 
		#   option is enabled.
		
		if [ "$USE_FONT_STRETCH" != "" ]
		then
			FONTNAME_SED_OPTIONS="$FONTNAME_SED_OPTIONS;
			   s/[cC][oO][nN][dD][eE][nN][sS][eE][dD]//g;
			   s/[nN][aA][rR][rR][oO][wW]//g;
			   s/[eE][xX][pP][aA][nN][dD][eE][dD]//g;"
		fi   
		
		#.. get rid of final "-" at the end of the font name, if it exists.
		FONTNAME_SED_OPTIONS="$FONTNAME_SED_OPTIONS
			     s/-$//"      
			     
		FONTNAME=`echo $INFO_FONTNAME | awk -F": " '{print $2}' |
			sed "$FONTNAME_SED_OPTIONS" | sed "s/[-_]*$//g"`
		FONTNAME="$FONT_PREFIX$FONTNAME"
		echo -n "Font: $FONTNAME"
		
		if [ "$FONT_STRETCH" != "normal" -a  "$FONT_STRETCH" != "" ]
		then
			echo -n ", stretch: $FONT_STRETCH"
		fi
		
		if [ "$FONT_WEIGHT" != "normal" -a  "$FONT_WEIGHT" != "" ]
		then
			echo -n ", weight: $FONT_WEIGHT"
		fi
		
		if [ "$FONT_STYLE" != "normal" -a  "$FONT_STYLE" != "" ]
		then
			echo -n ", style: $FONT_STYLE"
		fi
		echo
	else  
		FONTNAME="$FONT_PREFIX`getFontName $i.$ORIG_TYPE`"
		echo "Font: $FONTNAME"
	fi

	if [ "$IS_OTF" = "0" ]
	then
		EXTRA_FONT_INFO=" url('$i.otf')  format('opentype'),
      "
	else 
		EXTRA_FONT_INFO=""
	fi

	
  if [ "$USE_FONT_WEIGHT" != "" ]
  then
  
  
		RULE="
@font-face {
  font-family: '$FONTNAME';
  src: url('$i.eot?') format('eot'),"

if [ "$HAS_WOFF2_COMPRESS" = "0" -a -f "$i.woff" ]
then
	RULE="$RULE
       url('$i.woff2') format('woff2'),"
fi

RULE="$RULE
       url('$i.woff') format('woff'),
      $EXTRA_FONT_INFO url('$i.ttf')  format('truetype');
  font-weight: $FONT_WEIGHT;
  font-style: $FONT_STYLE;"
	
	
	
	if [ "$USE_FONT_STRETCH" != "" ]
	then

		RULE="$RULE
	font-stretch: $FONT_STRETCH;"
	
	fi
	
	RULE="$RULE
}" 

  echo "$RULE" >> $STYLESHEETFILE
  else
 
		# echo "Extracting SVG ID"
		SVG_ID=`getSVGID $i.svg`
	
    echo "
@font-face {
  font-family: '$FONTNAME';
  src: url('$i.eot?') format('eot')," >> $STYLESHEETFILE

  if [ "$HAS_WOFF2_COMPRESS" = "0" -a -f "$i.woff2" ]
  then
		echo "       url('$i.woff2') format('woff2')," >> $STYLESHEETFILE
  fi

echo "       url('$i.woff') format('woff'),
      $EXTRA_FONT_INFO url('$i.ttf')  format('truetype'),
       url('$i.svg#$SVG_ID') format('svg');
}" >> $STYLESHEETFILE
  fi
done
echo "DONE!"
