#!/bin/ksh
#
file=$1
OLDNAME=$2
#
TMPFILE="/tmp/tmpfile1.$$"
strings $file | grep -E -q "$OLDNAME"
if [ $? -eq 0 ]
then
 echo "Filename : $file"
 strings $file | grep -E "$OLDNAME"
fi
#
