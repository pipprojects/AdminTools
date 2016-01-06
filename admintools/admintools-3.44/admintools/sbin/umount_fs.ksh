#!/bin/ksh
#
HOST=$1
FSTAB=$2
#
NUMLINES="$(cat $FSTAB | wc -l)"
let "i=NUMLINES"
while [ i -ge 1 ]
do
 fs="$(cat $FSTAB | sed -e ${i}p -n | sed -e s@"/$"@@)"
 echo "umount -v /${HOST}${fs}"
 umount -v /${HOST}${fs}
 let "i=i-1"
done
#

