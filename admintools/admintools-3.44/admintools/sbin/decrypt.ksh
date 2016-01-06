#!/bin/ksh
#
TEXT=$1
#
FIRST_CHAR=31
LAST_CHAR=126
PRINT_OFFSET=32
NUMCHARS=$(echo $TEXT | od -tu1 -N 1 | awk '{print $2}')
FCHAR=${NUMCHARS}
NLEN=${#TEXT}
let "NLEN=FCHAR - PRINT_OFFSET"
let "X=1"
while [ $X -le $NLEN ]
do
 NUM=$(echo $TEXT | od -tu1 -j $X -N 1 | awk '{print $2}')
 let "NVAL = NUM - X"
 if [ $NVAL -le $FIRST_CHAR ]
 then
  let "NVAL=LAST_CHAR + (NVAL - FIRST_CHAR)"
 else
  let "NVAL=NVAL"
 fi
 let "NUM=X-1"
 NVAL1=$(printf "%o" $NVAL)
 NVAL2=$(echo "\0${NVAL1}")
 echo $NVAL2
 let "X=X+1"
done
#
