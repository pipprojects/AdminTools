#!/bin/bash
#
LOGBASE="/home/itsupport/ITData/log"
LOGDIR="${LOGBASE}/arplog"
if [ ! -d "${LOGDIR}" ]
then
 mkdir -p $LOGDIR
fi
HOST=$(hostname)
DATESTAMP=$(date '+%Y%m%d.%H%M%S')
FNAME="arplog.${HOST}.${DATESTAMP}.log"
FILE="${LOGDIR}/${FNAME}"
#
/sbin/arp -a >> $FILE
#
