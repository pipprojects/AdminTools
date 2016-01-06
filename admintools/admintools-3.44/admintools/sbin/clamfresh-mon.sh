#!/bin/bash
#
#*****************************************************************************
#
# Name          Description                     	Version Date
#
# Rob Dancer    Template Version taken from 		1.0	2 Dec 2004
#		genPicoLicence.sh
#
# Rob Dancer	freshclam				1.0	15 July 2005
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
 if [ $VERBOSE -eq 1 ]
 then
  _Log 1 "Ending $PROGNAME" 0 $SENDEML 1
 fi
 exit $1
}
#
# Help function 
#               
function _printHelp {
 let "i=1"
 while [ $i -le $NUMHELP ]
 do
  echo "${HELPINFO[${i}]}"
  let "i=i+1"   
 done
} 
#
# Examples
#               
function _printExamples {
 echo
 echo
 echo "Example 1. Print Help"
 echo " $PROGNAME -h"
 echo
 echo "Example 2. Print Help and Examples"
 echo " $PROGNAME -H"
 echo
}
#
# Log function
#
function _Log {
 LEVEL=$1
 MESSAGE="$2"
 OUTSDT=$3
 OUTEML=$4
 OUTLGF=$5
#
 LOGLEVELNONE=0
 LOGLEVELINFO=1
 LOGLEVELWARN=2
 LOGLEVELERR=3
#
 ALEVEL[${LOGLEVELNONE}]=""
 ALEVEL[${LOGLEVELINFO}]="Info: "
 ALEVEL[${LOGLEVELWARN}]="Warning: "
 ALEVEL[${LOGLEVELERR}]="Error: "
#
 MLEVEL=${ALEVEL[${LEVEL}]}
 if [ $LEVEL -eq $LOGLEVELNONE ]
 then
  DATESTAMPL=""
  PROGINFO=""
 else
  DATESTAMPL="`date` "
  PROGINFO="${PROGNAME}[${CPID}]: "
 fi
 MESSAGEOUT="${DATESTAMPL}${PROGINFO}${MLEVEL}${MESSAGE}"
#
# Send message to screen
#
 if [ "$OUTSDT" -ne 0 ]
 then
  echo $MESSAGEOUT
 fi
#
# Send message to Email
#
 if [ "$OUTEML" -ne 0 ]
 then
  echo $MESSAGEOUT >> $EMAILLOGFILE
 fi
#
# Send message log file
#
 if [ "$OUTLGF" -ne 0 ]
 then
  echo $MESSAGEOUT >> $APPLOGFILE
 fi
#
# Set send email flag
#
 if [ $LEVEL -eq $LOGLEVELERR ]
 then
  LOGERROR=1
 fi
#
}
#
# Get STDOUT
#
function _getOutput {
 COMMAND="$*"
 $COMMAND > $TMPFILE 2>&1
 if [ $SENDSTD -eq 1 ]
 then
  cat $TMPFILE
 fi
 if [ $VERBOSE -eq 1 ]
 then
  TMPINFO=$(cat $TMPFILE)
  _Log 1 "$TMPINFO" 0 $SENDEML 1
  rm -f $TMPFILE
 fi
}
#
# Main function
#
function _Main {
#
# Insert user function here
#
#
 PROC=$(ps -efw | grep "/usr/bin/freshclam" | grep -v grep)
 if [ -z "${PROC}" ]
 then
  service freshclam restart 2>&1
 fi
#
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
#PROGNAME=$(basename $0)
#CPID=$$
#EMAILLOGFILE="${PROGNAME}.${CPID}.email.log"
#APPLOGFILE="${PROGNAME}.log"
SENDEML=0
TMPFILE="/tmp/tmp.${PROGNAME}.$$.tmp"
#
# Set up user variables
#
OPTION=""
FILE=""
VERBOSE=0
SENDSTD=1
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$PROGNAME [-q] [-v] [-h] [-H] [-V]"
HELPINFO[1]="-v Verbose"
HELPINFO[2]="-q Quite output (none to stdio/stderr)"
HELPINFO[3]="-h This help"
HELPINFO[4]="-H Help and examples"
HELPINFO[5]="-V Version"
NUMHELP=5
#
while getopts qvhHV OPT
do
 case $OPT in
#
# Invalid option
#
        \?)
                if [ -z "$OPTARG" ]
                then
		 _Log 0 "$VERSION" 1 $SENDEML 0
		 _Log 0 "$USAGE" 1 $SENDEML 0
                 _exit 2
                fi
        ;;
#
# Help
#
	h)
                echo $USAGE
		_printHelp
		_exit 0
	;;
#
# Examples
#
	H)
                echo $USAGE
		_printHelp
		_printExamples
		_exit 0
	;;
#
# Quiet
#       
	q)      
		SENDSTD=0
	;;
#
# Verbose
#
	v)
		VERBOSE=1
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
# Starting info
#
if [ $VERBOSE -eq 1 ]
then
 _Log 1 "Starting $PROGNAME" 0 $SENDEML 1
fi
_Log 1 "$PROGNAME $*" 0 $SENDEML 1
#
# Check for show version
#
if [ "$SHOWVERSION" = "TRUE" ]
then
 SENDEML=0
 _Log 0 "$VERSION" 1 $SENDEML 0
 _Log 0 "$USAGE" 1 $SENDEML 0
 _exit $EXITSTAT
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
