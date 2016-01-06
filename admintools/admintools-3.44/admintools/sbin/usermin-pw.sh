#!/bin/bash
#
#
# This script is run after ther NIS password has been changed.
# It will use the encrypted password to set the other passwords.
# If the variable passwd to this script is not the same as the password
# set by yppasswd (or in /etc/shadow) then it is ignored and the NIS (shadow)
# file is used
#
# Rob Dancer	2	18th June 2012
# Change ssh host
#
#
DATESTAMP=$(date '+%Y%m%d.%H%M%S')
PWDIR="/home/itsupport/ITData/Record-PW"
PWLOGD="${PWDIR}/log"
PWLOG="${PWLOGD}/PW-change.log"
PWFILE="${PWDIR}/PW-record.txt"
if [ ! -d "$PWLOGD" ]
then
 mkdir -p $PWLOGD
fi
#
UPFILE="${PWDIR}/upfile.${DATESTAMP}.txt"
echo "$CHANGEPASS_USER" > $UPFILE
echo "$CHANGEPASS_PASS" >> $UPFILE
#
ssh shell-ba1 "/home/pcadmin/createuser/bin/record-pw.sh -f $UPFILE -P $PWFILE" >> $PWLOG
#
