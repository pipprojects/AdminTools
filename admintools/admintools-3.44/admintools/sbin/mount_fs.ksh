#!/bin/ksh
#
HOST=$1
FSTAB=$2
#
NUMLINES="$(cat $FSTAB | wc -l)"
let "i=1"
while [ i -le $NUMLINES ]
do
 fs="$(cat $FSTAB | sed -e ${i}p -n | sed -e s@"/$"@@)"
 echo "mount ${HOST}:/${fs} /${HOST}${fs}"
 mount ${HOST}:/${fs} /${HOST}${fs}
 let "i=i+1"
done
#
