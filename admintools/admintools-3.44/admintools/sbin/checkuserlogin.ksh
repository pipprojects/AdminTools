#!/bin/ksh
#
USER="$1"
#
TMPFILE="/tmp/tmpfile.$$"
#
while [ 1 ]
do
 who | grep "${USER} " > $TMPFILE
 if [ `cat $TMPFILE | wc -l` -ne 0 ]
 then
#  echo "${USER} login info" | cat - $TMPFILE | sendmail -v rob.dancer@172.19.16.129
  echo "${USER} login info"
  cat $TMPFILE
  echo "\007"
  echo "\007"
  echo "\007"
  echo "\007"
  echo "\007"
  echo "\007"
 fi
 rm $TMPFILE
 sleep 5
done
#
