#!/bin/ksh
#
SSTRINGT="$1"
#
for file in `find . -type f`
do
 strings $file | grep -qi "$SSTRINGT"
 if [ $? -eq 0 ]
 then
  echo "$file"
  strings $file | grep -i "$SSTRINGT"
 fi
done
#
