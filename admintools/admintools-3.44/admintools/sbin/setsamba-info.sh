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
# Rob Dancer	1.5	28 June 2007
# setsamba-info.sh
#
# Rob Dancer	1.6	22 August 2007
# Use cp and rm not mv to change samb.conf file as it is a link on yeo
#
#
VERSION="1.6, 22 August 2007"
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
 SMBPWFILE="/etc/samba/smbpasswd"
 LINE=$(cat $SMBPWFILE | grep "^${USERNAME}:")
#
 _ADM__CheckLogin $SERVER 0
#
 if [ $_ADM_NAMEOK -eq 1 ]
 then
  if [ $_ADM_SSHLOGIN -eq 1 ]
  then
#
   if [ $VERBOSE -eq 1 ]
   then
    _Log 1 "For server $SERVER" 1 $SENDEML 1
   fi
#
   ssh $SERVER "cat $SMBPWFILE | sed -e s/\"^${USERNAME}:.*\"/\"${LINE}\"/ > $TMPFILE; cp $TMPFILE $SMBPWFILE; rm -f $TMPFILE"
#
  else
   _Log 1 "Cannot connect to server $SERVER" 1 $SENDEML 1
  fi
 else
  _Log 1 "Unknown server $SERVER" 1 $SENDEML 1
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
USERNAME=""
SERVER=""
VERBOSE=0
SENDSTD=1
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$PROGNAME -u username -s host [-q] [-v] [-h] [-H] [-V]"
HELPINFO[1]="-u Username"
HELPINFO[2]="-s Sambao host"
HELPINFO[3]="-v Verbose customer information"
HELPINFO[4]="-q Quiet output (none to stdio/stderr)"
HELPINFO[5]="-h This help"
HELPINFO[6]="-H Help and examples"
HELPINFO[7]="-V Version"
NUMHELP=7
#
while getopts u:s:qvhHV OPT
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
# Username
#
	u)
		USERNAME="$OPTARG"
	;;
#
# Samba server
#
	s)
		SERVER="$OPTARG"
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
# Username
#
if [ -z "$USERNAME" ]
then
 _ADM__Log 3 "Username must be supplied" 1 $SENDEML 0
 _ADM__Log 0 "$USAGE" 1 $SENDEML 0
 EXITSTAT=1
 _ADM__exit $EXITSTAT
fi
#
# Samba Server
#
if [ -z "$SERVER" ]
then
 _ADM__Log 3 "Samba host must be supplied" 1 $SENDEML 0
 _ADM__Log 0 "$USAGE" 1 $SENDEML 0
 EXITSTAT=2
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
