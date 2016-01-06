#!/bin/bash
#
FILE="/tmp/tmp.$$.tmp"
ifconfig | sed -e s/"^"/":"/g > $FILE
NUMLINES=$(cat $FILE | wc -l)
let "j=0"
let "i=1"
while [ $i -le $NUMLINES ]
do
 LINE=$(cat $FILE | sed -e ${i}p -n)
 MATCH=$(echo $LINE | grep -E "^:[a-zA-Z]+")
 if [ -n "$MATCH" ]
 then
  let "j=j+1"
  _DEVNAME[$j]=$(echo $MATCH | sed -e s/"^:"/""/ | awk '{print $1}')
  _MACID[$j]=$(echo $MATCH | awk '{a=index($0,"HWaddr");
		if ( a != 0 ) {printf "%s",substr($0,a+7,17)}}')
 fi
#
 MATCH=$(echo $LINE | grep -E "inet addr:")
 if [ -n "$MATCH" ]
 then
  _IP[$j]=$(echo $MATCH | awk '{for (i=1;i<=NF;i++) {
		if ( $i ~ /^addr:/ ) {printf "%s",$i}}}' | cut -d ":" -f2)
  _BC[$j]=$(echo $MATCH | awk '{for (i=1;i<=NF;i++) {
		if ( $i ~ /^Bcast:/ ) {printf "%s",$i}}}' | cut -d ":" -f2)
  _NM[$j]=$(echo $MATCH | awk '{for (i=1;i<=NF;i++) {
		if ( $i ~ /^Mask:/ ) {printf "%s",$i}}}' | cut -d ":" -f2)
 fi
#
 let "i=i+1"
done
#
let "k=1"
_NUMDEV=$j
echo "There are $_NUMDEV network devices"
while [ $k -le $_NUMDEV ]
do
 echo "Device $k"
 echo " ${_DEVNAME[$k]}"
 echo " ${_MACID[$k]}"
 echo " ${_IP[$k]}"
 echo " ${_BC[$k]}"
 echo " ${_NM[$k]}"
#
 let "k=k+1"
done
#
