#!/bin/bash
#
HN=$(hostname | cut -d "." -f1)
NAME=$LOGNAME
FILE="${HOME}/.ssh/id_dsa-${HN}-${LOGNAME}"
FILE2="${HOME}/.ssh/id_dsa-${HN}-${LOGNAME}.priv"
FILE3="${HOME}/.ssh/id_dsa"
ssh-keygen -t dsa -f $FILE
cp $FILE $FILE2
mv $FILE $FILE3
#
