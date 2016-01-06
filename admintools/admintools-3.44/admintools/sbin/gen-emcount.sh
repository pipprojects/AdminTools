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
#
VERSION="1.0, 4 June 2007"
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
cd $UHDIR
#
OVERW=Y
cd $IMAPF
FOLDER="$(echo ${IMAPF})"
echo "Info: Look in files in folder ${FOLDER} account $USERNAME for email counts"
SMES=""
PMFILE="rc.count-emails"
a=$PWD
_setsupemails  "$USERNAME" "$IMAPF" "$PMFILE" "$SMES" "$OVERW"
cd $a
#
#
# Set up return status
#
 RETSTAT=0
}
function _setsupemails {
#
#*****************************************************************************
#
# Rob Dancer	V1.0	20th December 2006
# Antispam.*:
#
# Rob Dancer	V1.0	4 June 2007
# for support email
#
#*****************************************************************************
#
USERNAME="$1"
IMAPF="$2"
PMFILE="$3"
SMES=$4
OVERW="$5"
PMDIR=".procmaildir"
#
if [ -z "$IMAPF" ]
then
 IMAPF="."
fi
if [ -z "$OVERW" ]
then
 OVERW="Y"
fi
#
#
MESSAGE="$SMES"
#
if [ -z "$PMFILE" ]
then
 PMFILE=".procmailrc"
fi
DATESTAMP=$(date)
#
echo "For user: $UCOMMENT"
#
cd $UHDIR
if [ ! -d $PMDIR ]
then
 mkdir $PMDIR
fi
chown ${UUID}:${UGID} $PMDIR
chmod 750 $PMDIR
cd $PMDIR
#
touch $PMFILE
#
OUTFILE="procmail.sup.tmp"
> $OUTFILE
TAG="setupcountemails"
TAGSTART="#${TAG}++"
TAGEND="#${TAG}--"
#
TMPFILE="tmp.$$.tmp"
DIFFFILE="tmp.diff.$$.tmp"
NFILE="tmp.new.$$.tmp"
cat $PMFILE | sed /^#${TAG}++/,/^#${TAG}--/p -n > $TMPFILE
diff $TMPFILE $PMFILE > $DIFFFILE
touch $NFILE
patch -n $NFILE $DIFFFILE
cat $NFILE > $PMFILE
rm -f $TMPFILE $DIFFFILE $NFILE
#
echo "$TAGSTART" >> $OUTFILE
echo '#' >> $OUTFILE
echo "# $DATESTAMP" >> $OUTFILE
echo '#' >> $OUTFILE
echo "# Extract header information" >> $OUTFILE
echo ":0 c" >> $OUTFILE
echo "| /usr/bin/countemails.sh" >> $OUTFILE
echo "#" >> $OUTFILE
echo "$TAGEND" >> $OUTFILE
#
case $OVERW in
	Y)
		echo "Overwriting $PMFILE file"
		cat $OUTFILE > $PMFILE
	;;
	*)
		cat $OUTFILE >> $PMFILE
	;;
esac
#mv $OUTFILE $PMFILE
rm -f $OUTFILE
chown ${UUID}:${UGID} $PMFILE
chmod 600 $PMFILE
#
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
IMAPF=".countemails"
VERBOSE=0
SENDSTD=1
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$PROGNAME -u Username [-f CountFolder] [-q] [-v] [-h] [-H] [-V]"
HELPINFO[1]="-u Username"
HELPINFO[2]="-f Count mails folder [${IMAPF}]"
HELPINFO[3]="-v Verbose customer information"
HELPINFO[4]="-q Quiet output (none to stdio/stderr)"
HELPINFO[5]="-h This help"
HELPINFO[6]="-H Help and examples"
HELPINFO[7]="-V Version"
NUMHELP=7
#
while getopts u:f:qvhHV OPT
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
		USERNAME=$OPTARG
	;;
#
# IMAP Folder
#
	f)
		IMAPF="$OPTARG"
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
# Get user info
#
LINE=$(ypmatch ${USERNAME} passwd)
UUID=$(echo $LINE | cut -d ":" -f3)
UGID=$(echo $LINE | cut -d ":" -f4)
UCOMMENT=$(echo $LINE | cut -d ":" -f5)
UHDIR=$(echo $LINE | cut -d ":" -f6)
#
# Check bounds of USERNAME
#
if [ -z "$USERNAME" ]
then
 _ADM__Log 3 "Invalid option - $USERNAME" 1 $SENDEML 1
 _ADM__Log 1 "$USAGE" 1 $SENDEML 1
 EXITSTAT=1
 _ADM__exit $EXITSTAT
else
 OPTION=$OPTION
fi
#
# Check bounds of IMAPF
#
cd $UHDIR
if [ -n "${IMAPF}" ]
then
 if [ ! -e "${IMAPF}" ]
 then
  _ADM__Log 1 "Creating $IMAPF directory" 1 $SENDEML 1
  mkdir -p $IMAPF
  chown ${UUID}:${UGID} $IMAPF
  chmod 755 $IMAPF
 else
  if [ ! -d "${IMAPF}" ]
  then
   _ADM__Log 3 "$IMAPF is not a directory" 1 $SENDEML 1
   EXITSTAT=2
   _ADM__exit $EXITSTAT
  else
   _ADM__Log 1 "$IMAPF already exists" 1 $SENDEML 1
  fi
 fi
else
 IMAPF="./"
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
