#!/bin/bash
#
#*****************************************************************************
#
# Name          Description                     Version Date
#
# Rob Dancer    Initial version			1.0     11 Nov 1997
#
# Rob Dancer    Changed "Exit OK" to "Exit"	1.1     17 Nov 1997
#
# Rob Dancer    Set return status correctly	1.2     18 Nov 1997
#
# Rob Dancer    References amended to           2.0     01 Dec 1997
#               "admintools"
#
# Rob Dancer    Changed spelling mistake	2.1     10 Dec 1997
#		"exits"
#
# Rob Dancer    Exit with variable not		2.2     18 Dec 1997
#		explicitly 0 when showing
#		version
#
# Rob Dancer    Add default -f FILE option	2.3     22 Apr 1998
#
# Rob Dancer    Change getopt to getopts	2.4     23 Apr 1998
#
# Rob Dancer	copyemaillists.sh		1.0	23 March 2004
#
# Rob Dancer	copyemailinfo.sh		1.0	05 April 2004
#		Added virtusertable
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
cp $EMLIST $DESTDIR
if [ -n "$OWNER" -o -n "$GROUP" ]
then
 chown ${OWNER}${SEP}${GROUP} ${DESTDIR}/${EMLIST}
fi
#
# Loop round files
#
for file in `cat $EMLIST`
do
 cp -f $file ${DESTDIR}
 if [ -n "$OWNER" -o -n "$GROUP" ]
 then
  chown ${OWNER}${SEP}${GROUP} ${DESTDIR}/${file}
 fi
done
#
# Copy virtual file
#
cd /etc/mail
#
cp $EMVFILE $DESTDIR
if [ -n "$OWNER" -o -n "$GROUP" ]
then
 chown ${OWNER}${SEP}${GROUP} ${DESTDIR}/${EMVFILE}
fi
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
EMVFILE="virtusertable"
DESTDIR="/root"
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$0 [-l ListFile] [-d DestinationFile] [-o Owner] [ -g Group] [-V Version]"
while getopts l:d:o:g:V OPT
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
# Destination Directory
#
	d)
		DESTDIR=$OPTARG
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
  echo "ERROR : Directory $EMLIST does not exist or cannot be opened"
  EXITSTAT=2
 _exit $EXITSTAT
 fi
fi
#
# Check bounds of DESTDIR
#
if [ -z "$DESTDIR" ]
then
 echo "ERROR : Destination directory required"
 echo "$USAGE"
 EXITSTAT=3
 _exit $EXITSTAT
else
 if [ ! -r "$DESTDIR" ]
 then
  echo "ERROR : Directory $DESTDIR does not exist or cannot be opened"
  EXITSTAT=4
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
