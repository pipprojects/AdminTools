#!/bin/ksh
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
# Rob Dancer    Initial version of		2.5	01 Nov 1999
#		send_text_message.ksh 
#
# Rob Dancer    Add option for alternate phone	2.6	02 Nov 1999
#		file
#
VERSION="2.6, 02 Nov 1999"
#
#*****************************************************************************
#
# Exit function
#
function _exit {
 exit $1
}
#
# Get number from parameter
#
function _get_number
{
MSISDN=$1
NUMBERS=$(echo "$MSISDN" | awk '{PASS="TRUE"; for (i=1;i<=length($1);i++){if (substr($1,i,1) !~ /[0-9+]/){PASS="FALSE"}else{printf "%s",substr($1,i,1)}}print ""; if (PASS=="TRUE"){print $1}}')
echo $NUMBERS
}
#
# Get number in correct format
#
function _unify_number
{
NUMBERS=$1
NUMBER=$(echo $NUMBERS | awk '{print $2}')
#
MSISDN=$NUMBER
NUMBER=${MSISDN##44}
MSISDN=$NUMBER
NUMBER=${MSISDN##+44}
MSISDN=$NUMBER
NUMBER=${MSISDN##0}
MSISDN="44${NUMBER}"
echo $MSISDN
}
#
# Main function
#
function _Main {
#
# Insert user function here
#
NUMBERS=$(_get_number $NAMENUMBER)
NUMNUMBERS=$(echo $NUMBERS | wc -w)
#
if [ $NUMNUMBERS -le 1 ]
then
 PERSON=$NAMENUMBER
 MSISDN=$(cat $PHONEFILE | sed -e s/"#.*"//g -e s/"[	 ]"/" "/g -e s/"  *"/" "/g -e /^$/d -e s/"$"/" "/g | grep " ${PERSON} " | awk '{print $1}')
 if [ -z "$MSISDN" ]
 then
  echo "ERROR : There is no entry in $PHONEFILE for this person"
  RETSTAT=4
 else
  NUMBERS=$(_get_number $MSISDN)
  echo "Name"
  echo $PERSON
 fi
fi
#
MSISDN=$(_unify_number "$NUMBERS")
echo "Telephone number"
echo $MSISDN
#
MESSAGE="$(cat $MESSAGEFILE | sed -e s/\"/\\\"/g | awk '{printf "%s ",$0}END{print}')"
echo $MESSAGEPROG $MSISDN "$MESSAGE"
$MESSAGEPROG $MSISDN "$MESSAGE" 2>>$MESSAGELOG
#
# Set up return status
#
 RETSTAT=$?
}
#
# Start here
#
#
# Source setup file
#
#. /etc/admintools.src
SHOWVERSION="FALSE"
#
# Set up user variables
#
NAMENUMBER=""
MESSAGEFILE=""
MESSAGEPROG="/usr/local/bin/message.sh"
PHONEFILE="/etc/phonenumbers"
MESSAGELOG="/var/adm/textmessage.log"
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$0 -n name|number -f message_file [-p phone_numbers_file] [-V Version]"
while getopts n:f:p:V OPT
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
# Name or number
#
	n)
		NAMENUMBER=$OPTARG
	;;
#
# Message file
#
	f)
		MESSAGEFILE=$OPTARG
	;;
#
# Phone numbers file
#
	p)
		PHONEFILE=$OPTARG
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
# Check bounds of NAMENUMBER
#
if [ -z "$NAMENUMBER" ]
then
 echo "ERROR : Name or number required"
 echo $USAGE
 EXITSTAT=1
 _exit $EXITSTAT
fi
#
# Check bounds of MESSAGEFILE
#
if [ -z "$MESSAGEFILE" ]
then
 echo "ERROR : Filename required"
 echo "$USAGE"
 EXITSTAT=2
 _exit $EXITSTAT
else
# If not stdin
 if [ "$MESSAGEFILE" != "-" ]
 then
  if [ ! -r "$MESSAGEFILE" ]
  then
   echo "ERROR : File $MESSAGEFILE does not exist or cannot be opened"
   EXITSTAT=3
  _exit $EXITSTAT
  fi
 fi
fi
#
# Check bounds of PHONEFILE
#
if [ -z "$PHONEFILE" ]
then
 echo "ERROR : Phone numbers file required"
 echo "$USAGE"
 EXITSTAT=5
 _exit $EXITSTAT
else
# If not stdin
 if [ "$PHONEFILE" != "-" ]
 then
  if [ ! -r "$PHONEFILE" ]
  then
   echo "ERROR : Phone numbers file $PHONEFILE does not exist or cannot be opened"
   EXITSTAT=6
  _exit $EXITSTAT
  fi
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
_exit $EXITSTAT
#
