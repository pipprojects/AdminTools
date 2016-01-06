#!/bin/bash
#
FILEIN="$1"
MESSAGE="$2"
TMPFILE="tmp$$.tmp"
cat $FILEIN > $TMPFILE
SUBJECT=$(cat $TMPFILE | formail -u "Subject:" | grep "^Subject: " | head -n 1 | cut -d ":" -f2-)
SUBJECTNEW="${MESSAGE} ${SUBJECT}"
cat $TMPFILE  | formail -I "Subject: ${SUBJECTNEW}"
rm -f $TMPFILE
#
