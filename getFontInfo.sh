#!/bin/sh

if [ "$#" != 1 ]
then
	echo "Usage: $0 <font-files>" 1>&2
	exit 1
fi

ISBOLD=`echo $1 | grep -i bold > /dev/null; echo $?`
ISITALIC=`echo $1 | grep -i italic > /dev/null; echo $?`
ISCONDENSED=`echo $1 | egrep -i 'condensed|narrow' > /dev/null; echo $?`

echo $ISCONDENSED


