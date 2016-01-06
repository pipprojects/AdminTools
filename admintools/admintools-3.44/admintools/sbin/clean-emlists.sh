#!/bin/bash
#
#*****************************************************************************
#
# Name          Description                     Version Date
#
# R Dancer	Initial Veriosn			1.0	20th October 2006
#		CLeans email lists and removed
#		spaces and duplicates
#
# Rob Dancer    Move definitions to admntools.src	1.1     28 November 2006
#
#
VERSION="1.1, 28 November 2006"
#
#*****************************************************************************
#
# Exit function
#
function _exit {
 exit $1
}
#
# Main function
#
function _Main {
#
# Insert user function here
#
cd /etc/mail/emailgroups
#
# Loop round files
#
TMPFILE="tmp.$$.tmp"
for file in `cat $EMLIST | cut -d ":" -f1`
do
 if [ -n "$OWNER" -o -n "$GROUP" ]
 then
  chown ${OWNER}${SEP}${GROUP} ${file}
  cat $file | sed -e s/"[	 ]"//g | sort -u | grep -v "^$" > $TMPFILE
  cat $TMPFILE > $file
  chown ${OWNER}${SEP}${GROUP} ${file}
  rm -f $TMPFILE
 fi
done
#
# Set up return status
#
 RETSTAT=0
}
#
# Start here
#
#
# Source setup file
#
. /etc/admintools.src
SHOWVERSION="FALSE"
#
# Set up user variables
#
EMLIST="emlists.txt"
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$0 [-l ListFile] [-o Owner] [ -g Group] [-V Version]"
while getopts l:o:g:V OPT
do
 case $OPT in
#
# Invalid option
#
        \?)
                if [ -z "$OPTARG" ]
                then
                 echo $USAGE
                 _exit 2
                fi
        ;;
#
# Email list file
#
	l)
		EMLIST=$OPTARG
	;;
#
# Owner
#
	o)
		OWNER=$OPTARG
	;;
#
# GROUP
#
	g)
		GROUP=$OPTARG
	;;
#
# Show version
#
	V)
		SHOWVERSION="TRUE"
	;;
 esac
done
#
# Check for show version
#
if [ "$SHOWVERSION" = "TRUE" ]
then
 echo "$VERSION"
 echo "$USAGE"
 _exit $EXITSTAT
fi
#
# Check bounds of EMLIST
#
if [ -z "$EMLIST" ]
then
 echo "ERROR : Email file list not specified"
 echo "$USAGE"
 EXITSTAT=1
 _exit $EXITSTAT
else
 if [ ! -r "$EMLIST" ]
 then
  echo "ERROR : File $EMLIST does not exist or cannot be opened"
  EXITSTAT=2
 _exit $EXITSTAT
 fi
fi
#
# Check group
#
if [ -z "$GROUP" ]
then
 SEP=""
else
 SEP=":"
fi
#
# Do Main
#
_Main
let "EXITSTAT=EXITSTAT+RETSTAT"
#
# Exit
#
_exit $EXITSTAT
#
