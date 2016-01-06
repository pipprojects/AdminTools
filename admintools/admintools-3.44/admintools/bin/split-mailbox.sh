#!/bin/bash
#
#*****************************************************************************
#
# Name          Description                     	Version Date
#
# Rob Dancer    Template Version taken from 		1.0	2 Dec 2004
#		genPicoLicence.sh
#
# Rob Dancer	split-mailbox.sh			1.0	6 Jan 2005
#
# Rob Dancer	Move definitions to admntools.src	1.1	28 November 2006
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
_Log 1 "Getting length of mailbox (this may take some time)" 1 $SENDEML 0
NUMLINES=$(cat $MAILBOXFILE | wc -l)
_Log 1 "Mailbox file $MAILBOXFILE is $NUMLINES lines long" 1 $SENDEML 0
_Log 1 "Getting Number of emails in mailbox (this may take some time)" 1 $SENDEML 0
LISTFILE=".tmpfile-${PROGNAME}-$$.tmp"
cat $MAILBOXFILE | grep -n "^From " > $LISTFILE
NUMEMAILS=$(cat $LISTFILE | wc -l)
_Log 1 "Mailbox file $MAILBOXFILE contains $NUMEMAILS emails" 1 $SENDEML 0
#
EMAILSPERSPLIT=$(echo $NUMEMAILS $NUMSPLITS | awk '{printf "%d",$1/$2}')
EMAILSLAST=$(echo $EMAILSPERSPLIT $NUMEMAILS $NUMSPLITS | awk '{printf "%d",$2-($1*($3-1))}')
_Log 1 "There will be $EMAILSPERSPLIT emails per file" 1 $SENDEML 0
_Log 1 "The last file will contain $EMAILSLAST emails" 1 $SENDEML 0
#
let "i=1"
let "linenum=0"
let "mblinenumstart=1"
let "mblinenumend=mblinenumstart-1"
while [ $i -le $NUMSPLITS ]
do
 if [ $i -eq $NUMSPLITS ]
 then
  let "mblinenumstart=mblinenumend+1"
  let "mblinenumend=NUMLINES"
 else
  let "linenum=(i*EMAILSPERSPLIT)+1"
  line=$(cat $LISTFILE | sed -e ${linenum}p -n)
  mblinenum=$(echo $line | cut -d ":" -f1)
  let "mblinenumstart=mblinenumend+1"
  let "mblinenumend=mblinenum-1"
 fi
 _Log 1 "Getting emails from $mblinenumstart to $mblinenumend" 1 $SENDEML 0
 SPLITFILE="${MAILBOXFILE}-${i}"
 cat $MAILBOXFILE | sed ${mblinenumstart},${mblinenumend}p -n > $SPLITFILE
 let "i=i+1"
done
#
if [ -f $LISTFILE ]
then
 rm -f $LISTFILE
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
#PROGNAME=$(basename $0)
#CPID=$$
#EMAILLOGFILE="${PROGNAME}.${CPID}.email.log"
#APPLOGFILE="${PROGNAME}.log"
SENDEML=0
TMPFILE="/tmp/tmp.${PROGNAME}.$$.tmp"
#
# Set up user variables
#
MAILBOXFILE=""
NUMSPLITS=2
MINSPLITS=1
MAXSPLITS=128
VERBOSE=0
SENDSTD=1
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$PROGNAME -m mailboxfile [-n number_of_splits] [-q] [-v] [-h] [-H] [-V]"
HELPINFO[1]="-m Mailbox file"
HELPINFO[2]="-n Number of splits"
HELPINFO[3]="-v Verbose customer information"
HELPINFO[4]="-q Quiet output (none to stdio/stderr)"
HELPINFO[5]="-h This help"
HELPINFO[6]="-H Help and examples"
HELPINFO[7]="-V Version"
NUMHELP=7
#
while getopts m:n:qvhHV OPT
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
# Mailbox File
#
	m)
		MAILBOXFILE=$OPTARG
	;;
#
# Number of splits
#
	n)
		NUMSPLITS=$OPTARG
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
# Check bounds of NUMSPLITS
#
# Convert to number
#
let "NUMSPLITS=NUMSPLITS"
if [ $NUMSPLITS -lt $MINSPLITS -o $NUMSPLITS -gt $MAXSPLITS ]
then
 _Log 3 "Number of splits out of range (= $NUMSPLITS) - $MINSPLITS to $MAXSPLITS" 1 $SENDEML 1
 _Log 1 "$USAGE" 1 $SENDEML 1
 EXITSTAT=1
 _exit $EXITSTAT
fi
#
# Check bounds of MAILBOXFILE
#
if [ -z "$MAILBOXFILE" ]
then
 _Log 3 "Filename required" 1 $SENDEML 1
 _Log 1 "$USAGE" 1 $SENDEML 1
 EXITSTAT=2
 _exit $EXITSTAT
else
 if [ ! -r "$MAILBOXFILE" ]
 then
  _Log 3 "File $MAILBOXFILE does not exist or cannot be opened" 1 $SENDEML 1
  _Log 1 "$USAGE" 1 $SENDEML 1
  EXITSTAT=3
  _exit $EXITSTAT
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
