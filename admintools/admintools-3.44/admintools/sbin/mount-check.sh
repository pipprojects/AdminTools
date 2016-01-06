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
# Rob Dancer	1.5	2 October 2007
# amend -f and -o options
#
# Rob Dancer	1.0	20 June 2008
# Check mounted filesystems in fstab and mtab
#
#
VERSION="1.0, 20 June 2008"
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
 MD=$(cat $FSTAB | awk -v "MATCH=${MFS}" '{if ( $2 == MATCH ){ print $1}}')
 if [ -z "$MD" ]
 then
  _ADM__Log 2 "$MFS not defined in $FSTAB" 1 $SENDEML 1
 else
  _ADM__Log 1 "$MFS should be mounted at $MD" 1 $SENDEML 1
#
  MATCH=$(cat $MTAB | awk -v MATCH="${MFS}" -v MD="${MD}" '{if ( $2 == MATCH && $1 == MD ){print $1}}')
 fi
#
 if [ -z "$MATCH" ]
 then
  if [ -z "$MD" ]
  then
   _ADM__Log 3 "$MFS not defined in $MTAB" 1 $SENDEML 1
  else
   _ADM__Log 3 "$MFS not found at $MD" 1 $SENDEML 1
  fi
  STATUS="NOTOK"
  ESTAT=1
 else
  _ADM__Log 1 "$MFS mounted at $MD" 1 $SENDEML 1
  STATUS="OK"
  ESTAT=0
 fi
 _ADM__Log 1 "STATUS: $STATUS" 1 $SENDEML 1
#
#
# Set up return status
#
 RETSTAT=$ESTAT
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
MFS=""
FSTAB="/etc/fstab"
MTAB="/etc/mtab"
MATCH=""
VERBOSE=0
SENDSTD=1
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$PROGNAME -f Filesystem [-q] [-v] [-h] [-H] [-V]"
HELPINFO[1]="-f Mounted filesystem to check"
HELPINFO[2]="-v Verbose information"
HELPINFO[3]="-q Quiet output (none to stdio/stderr)"
HELPINFO[4]="-h This help"
HELPINFO[5]="-H Help and examples"
HELPINFO[6]="-V Version"
NUMHELP=6
#
while getopts f:qvhHV OPT
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
# Filesystem
#
	f)
		MFS=$OPTARG
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
# Check for filesystem
#
if [ -z "$MFS" ]
then
 _ADM__Log 3 "Need a filesystem to check" 1 $SENDEML 1
 EXITSTAT=1
 _ADM__exit $EXITSTAT
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
