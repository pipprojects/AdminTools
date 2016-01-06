#!/bin/ksh
#
check_mount_backups.ksh | grep "WARNING" | awk '{print "i "$5}'
#
