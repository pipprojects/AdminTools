#!/bin/ksh
#
file=$2
for ip in `cat $2`
do
 cd $1
 for file in `ls`
 do
  /opt/admintools/sbin/change_text.ksh $file "$ip" "192.168.2.202"
 done
 cd -
done
#
