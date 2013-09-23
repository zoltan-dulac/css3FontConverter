#!/bin/sh

SCRIPT_DIR=`echo $0 | sed "s/getFontWeightStyle.sh//"`


getFontInfo() {
  OUT=`fontforge -script $SCRIPT_DIR/getFontInfo.pe $1 2> /dev/null`
  
  INFO_WEIGHT=`echo "$OUT" | egrep "^Weight:"` 
  INFO_FONTNAME=`echo "$OUT" | egrep "^Font name:"`
  INFO_FULLNAME=`echo "$OUT" | egrep "^Full name:"`
  INFO_ITALICANGLE=`echo "$OUT" | egrep "^Italic angle:"`
}

isWeightStyle () {
  STYLE="$1"
  R="F"

  echo "$INFO_WEIGHT" | grep -i $STYLE > /dev/null
  
  if [ "$?" = "0" ]
  then
  	R="T"
  else
  	echo "$INFO_FULLNAME" | grep -i $STYLE > /dev/null
  	if [ "$?" = "0" ]
  	then
  		R="T"
  	else 
  		
  		echo "$INFO_FONTNAME" | grep -i $STYLE > /dev/null
  
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

#.. first, get the info about the font from fontforge.
getFontInfo $1

#.. next, from the fontforge info, find out if the font is bold, italic and/or condensed.
IS_BOLD=`isWeightStyle 'bold'`
IS_ITALIC=`isWeightStyle 'italic'`
IS_CONDENSED=`isWeightStyle 'condensed'`

#.. condensed and narrow are the same (I believe).
if [ "$IS_CONDENSED" = "F" ]
then
  IS_CONDENSED=`isWeightStyle 'narrow'`
fi

#.. the name we will refer to in CSS will be without the words "Bold", "Italic", etc.
NEW_NAME=`echo $INFO_FONTNAME | awk -F": " '{print $2}' |
  sed 's/Bold//gi;
       s/Italic//gi;
       s/Narrow//gi;
       s/Condensed//gi;
       s/Regular//gi;
       s/-$//'  `

echo
echo "$OUT"
echo "==============="


echo "CSS Name: $NEW_NAME"
echo "IS BOLD: $IS_BOLD"
echo "IS ITALIC: $IS_ITALIC"
echo "IS CONDENSED: $IS_CONDENSED"
