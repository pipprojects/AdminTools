#!/bin/ksh
#
TAPEDEV=$1

fbackup -v -f $TAPEDEV -0i / -e /cdrom

mt -t $TAPEDEV offl

