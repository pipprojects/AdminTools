#!/bin/bash
#
#*****************************************************************************
#
# Name          Description                     	Version Date
#
# Rob Dancer    Template Version taken from 		1.0	2 Dec 2004
#		genPicoLicence.sh
#
# Rob Dancer    Move definitions to admntools.src	1.1     28 November 2006
#
# Rob Dancer	Change !Quite" to "Quiet"		1.2	11 April 2007
#
# Rob Dancer	Add admfunctions.src			1.3	11 May 2007
#
# Rob dancer	Make sure uses _ADM__Log not _Log	1.4	4 June 2007
#
# Rob Dancer	1.0	7 June 2007
# Initial Version
#
#
VERSION="1.0, 7 June 2007"
#
#*****************************************************************************
#
#
# Main function
#
function _Main {
#
# Insert user function here
#
#
DATESTAMP=$(date '+%Y%m%d.%H%M%S')
DATE=$(date)
echo "${DATE}: $TSMESSAGE" >> $LOGFILE
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
. /opt/admintools/etc/admfunctions.src
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
LOGFILE="/var/log/timestamp-event.log"
TSMESSAGE=""
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
USAGE="$PROGNAME [-f LogFile] [-m Message] [-q] [-v] [-h] [-H] [-V]"
HELPINFO[1]="-f Log file [/var/log/timestamp.log"
HELPINFO[2]="-m Message for logfile"
HELPINFO[3]="-v Verbose customer information"
HELPINFO[4]="-q Quiet output (none to stdio/stderr)"
HELPINFO[5]="-h This help"
HELPINFO[6]="-H Help and examples"
HELPINFO[7]="-V Version"
NUMHELP=7
#
while getopts f:m:qvhHV OPT
do
 case $OPT in
#
# Invalid option
#
        \?)
                if [ -z "$OPTARG" ]
                then
		 _ADM__Log 0 "$VERSION" 1 $SENDEML 0
		 _ADM__Log 0 "$USAGE" 1 $SENDEML 0
                 _ADM__exit 2
                fi
        ;;
#
# Help
#
	h)
                echo $USAGE
		_ADM__printHelp
		_ADM__exit 0
	;;
#
# Examples
#
	H)
                echo $USAGE
		_ADM__printHelp
		_ADM__printExamples
		_ADM__exit 0
	;;
#
# File
#
	f)
		LOGFILE="$OPTARG"
	;;
#
# Message
#
	m)	TSMESSAGE=$OPTARG
		
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
 _ADM__Log 1 "Starting $PROGNAME" 0 $SENDEML 1
fi
_ADM__Log 1 "$PROGNAME $*" 0 $SENDEML 1
#
# Check for show version
#
if [ "$SHOWVERSION" = "TRUE" ]
then
 SENDEML=0
 _ADM__Log 0 "$VERSION" 1 $SENDEML 0
 _ADM__Log 0 "$USAGE" 1 $SENDEML 0
 _ADM__exit $EXITSTAT
fi
#
# Check bounds of LOGFILEFILE
#
if [ -z "$LOGFILE" ]
then
 _ADM__Log 3 "Filename required" 1 $SENDEML 1
 _ADM__Log 1 "$USAGE" 1 $SENDEML 1
 EXITSTAT=2
 _ADM__exit $EXITSTAT
else
 touch $LOGFILE
 chmod 644 $LOGFILE
 if [ ! -w "$LOGFILE" ]
 then
  _ADM__Log 3 "File $LOGFILE does not exist or cannot be opened" 1 $SENDEML 1
  _ADM__Log 1 "$USAGE" 1 $SENDEML 1
  EXITSTAT=3
  _ADM__exit $EXITSTAT
 fi
fi
#
# Do Main
#
_Main
let "EXITSTAT=EXITSTAT+RETSTAT"
#
# Exit
#
_ADM__exit $EXITSTAT
#
