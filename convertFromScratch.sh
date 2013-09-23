#!/bin/sh

SCRIPT_DIR=`echo $0 | sed "s/convertFromScratch.sh//"`

$SCRIPT_DIR/convertFonts.sh --clean
rm hinted-*.ttf
$SCRIPT_DIR/convertFonts.sh --use-font-weight --output=weighted-stylesheet.css  $*
$SCRIPT_DIR/convertFonts.sh --use-font-weight --use-font-prefix=hinted- --autohint  --output=hinted-stylesheet.css *.ttf