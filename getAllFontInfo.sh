#!/bin/sh

for i in $1/*.ttf $1/*.otf
do 
	echo $i
	fontforge -script getFontInfo.pe $i 2> /dev/null 
	echo
done
