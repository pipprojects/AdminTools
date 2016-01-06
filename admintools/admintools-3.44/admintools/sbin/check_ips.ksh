#!/bin/ksh
cd $1
for file in `ls`
do
 /opt/admintools/sbin/check_text.ksh $file "[1-9]?[0-9]?[0-9]+\.[0-9]?[0-9]?[0-9]+\.[0-9]?[0-9]?[0-9]+\.[0-9]?[0-9]?[0-9]+"
done
#
