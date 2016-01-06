#!/bin/ksh
#
file=$1
OLDNAME=$2
NEWNAME=$3
#
TMPFILE="/tmp/tmpfile1.$$"
grep -q "$OLDNAME" $file
if [ $? -eq 0 ]
then
 echo "Changing $file"
 cat $file | sed -e s/"$OLDNAME"/"$NEWNAME"/g > $TMPFILE
 cp $TMPFILE $file
 rm $TMPFILE
else
 echo "Not changing $file"
fi
#
