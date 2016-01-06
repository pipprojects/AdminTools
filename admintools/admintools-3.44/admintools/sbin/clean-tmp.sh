#!/bin/bash
#
#
##
## Clean tmp
##
#00 01 * * * /opt/admintools/sbin/clean-tmp.sh
#
NUMDAYS="14"
FILED="/var/log"
FILEN="clean-tmp.log"
FILE="${FILED}/${FILEN}"
#
find /tmp ! -user 0 ! -name ".*" -type f -mtime +${NUMDAYS} -exec ls -ald {} \; >> ${FILE}
find /tmp ! -user 0 ! -name ".*" -type f -mtime +${NUMDAYS} -exec rm -f {} \; >> ${FILE} 2>&1
#
