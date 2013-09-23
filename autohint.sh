#!/bin/sh

for i in $*
do
	ttfautohint  --strong-stem-width=D --windows-compatibility --components  $i hinted-$i
done
