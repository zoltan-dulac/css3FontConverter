#!/bin/bash

#########################################################################
## CONFIGURATION AREA: This stuff is the only stuff you may need to     #
##                     change.                                          #
#########################################################################

# Linux and Mac users, this directory should be changed to be of this form:
# BATIK_DIR="/Users/webtest/src/batik".  Windows should use the form below.
BATIK_DIR='c:\Program Files\Batik\batik-1.7'

# The path should contain the directories where EOTFAST-1.EXE, ttf2eot,
# fontforge, and all the scripts in the @Font-Face Contruction Set reside.
# Uncomment the line below with the right directories.  Remember the 
# $PATH at the beginning of the string, or the script will forget what
# was originally in the PATH.
PATH="$PATH:/home/haw5855/src/fontforge-mingw_2010_05_18"

#########################################################################
## PROGRAM AREA                                                         #
#########################################################################

FILE_STUBS=''
SCRIPT_DIR=`echo $0 | sed "s/convertFonts.sh//"`

IFS=$(echo -en "\n\b")

toTTF () {
	if [ "$FONTFORGE_EXT" = "bat" ]
	then
		echo "(Using MingW FontForge)"
		$FONTFORGE -script `cygpath -w $SCRIPT_DIR/2ttf.pe` \
			`cygpath -w $i` 2> /dev/null
	else
		echo "(Using Cygwin FontForge)"
		$FONTFORGE -script $SCRIPT_DIR/2ttf.pe $i 
	fi
	
}

toEOT () {
	if [ -f "$SCRIPT_DIR/EOTFAST-1" ]
	then
		echo "(Using EOTFAST)"
		EOTFAST-1 $1
	else 
		echo "(Using ttf2eot)"
		FILE_STUB=`echo $NEW_FILE | 
			sed "s/\.[tT][tT][fF]$//" |
                        sed "s/\.[oO][tT][fF]$//"`
		ttf2eot $1 > $FILE_STUB.eot
	fi
}

toSVG() {
	if [ -f "$BATIK_DIR/batik-ttf2svg.jar" ]
	then 
	
		java -jar "$BATIK_DIR/batik-ttf2svg.jar"  \
			$1 -l 32 -h 127 -o $i.tmp -id $2 2> /dev/null

		cat $i.tmp | grep -v "<hkern" > $2.svg

		rm $i.tmp
	elif [ -f $SCRIPT_DIR/2svg.pe ]
	then
		fontforge -script $SCRIPT_DIR/2svg.pe $1
	else 
		echo "Error: cannot produce SVG font"
	fi
}

getFontName () { 
	if [ "$FONTFORGE_EXT" = "bat" ]
	then
		$FONTFORGE -script `cygpath -w $SCRIPT_DIR/getFontName.pe` \
			`cygpath $1` 2> /dev/null | tr ' ' '_'  |
			sed "s///g" 
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

if [ "$#" -eq "0" ]
then
	echo "Usage: $0 <font list>" 1>&2
	exit 1
fi

# .. check to make sure all packages are installed
for i in sfnt2woff java 
do
	which $i > /dev/null 2> /dev/null
	if [ "$?" != "0" ]
	then
		echo "Error: Package $i is not installed.  Bailing" 1>&2
		exit 2
	fi
done

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
	
if [ ! -f "$BATIK_DIR/batik-ttf2svg.jar" ]
then
	echo "Error: Batik is not installed or BATIK_DIR is not set. " 1>&2
	echo "Bailing." 1>&2

	exit 3
fi

HAS_EOT_SUPPORT=1
for i in EOTFAST-1 ttf2eot 
do
	which $i > /dev/null 2> /dev/null
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

for i in $*
do
	#.. check to see if it's a TrueType font
	file "$i" | grep "TrueType" > /dev/null
	IS_TTF="$?"

	file "$i" | grep "OpenType" > /dev/null
	IS_OTF="$?"

	if [ "$IS_OTF" = "0" ]
	then
		ORIG_TYPE="otf"
	elif [ "$IS_TTF" = "0" ]
	then
		ORIG_TYPE="ttf"
	fi

	if [ "$IS_OTF" = 0 -o "$IS_TTF" = 0 ]
	then
		cp $i old
	
		NEW_FILE=`echo $i | sed "s/ /_/g"`

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

		if [ "$IS_OTF" = "0" -a ! -f $FILE_STUB.ttf ]
		then 
			toTTF $NEW_FILE
			NEW_FILE="$FILE_STUB.ttf"
		fi

		if [ ! -f $FILE_STUB.eot ]
		then
			echo "Converting $FILE_STUB to eot"
			toEOT $NEW_FILE 
		else 
			echo "$FILE_STUB.eot exists, skipping ..."
		fi
	
		if [ ! -f $FILE_STUB.svg ]
                then
			echo "Converting $FILE_STUB to svg"
			toSVG $NEW_FILE $FILE_STUB
		else 
			echo "$FILE_STUB.svg exists, skipping ..."
		fi
	
		if [ ! -f $FILE_STUB.woff ]
                then
			echo "Converting $FILE_STUB to woff"
			toWOFF $NEW_FILE
		else 
			echo "$FILE_STUB.woff exists, skipping ..."
		fi
			 
	
		FILE_STUBS="$FILE_STUBS $FILE_STUB"
	else 
		echo "File $i is not a TrueType or OpenType font. Skipping"
	fi
done


echo "Writing Stylesheet ..."
IFS=$(echo -en " ")
for i in $FILE_STUBS
do
	if [ "$IS_OTF" = "0" ]
	then
		EXTRA_FONT_INFO=" url('$i.otf')  format('opentype'),
	    "
	else 
		EXTRA_FONT_INFO=""
	fi

	echo "Extracting SVG ID"
	SVG_ID=`getSVGID $i.svg`
	
	echo "Getting Font Name"
	FONTNAME=`getFontName $i.$ORIG_TYPE`

	echo "
@font-face {
	font-family: '$FONTNAME';
	src: url('$i.eot'); /* IE9 in IE7/IE8 compatability mode */ 
	src: url('$i.eot?') format('eot'), 
	    $EXTRA_FONT_INFO url('$i.woff') format('woff'), 
	     url('$i.ttf')  format('truetype'),
	     url('$i.svg#$SVG_ID') format('svg');
}" >> stylesheet.css
done
echo "DONE!"
