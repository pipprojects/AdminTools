#!/bin/bash
#
#*****************************************************************************
#
# Name          Description                     	Version Date
#
# Rob Dancer    Template Version taken from 		1.0	2 Dec 2004
#		genPicoLicence.sh
#
# ROb Dancer	1.1	1 October 2007
# Add locvation
#
#
VERSION="1.1 1 October 2007"
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
#1_username:2_crypt_passwd:3_uid:4_gid:5_Comment:6_shell:7_pc_name:8_pc_ip:9_add_samba:10_pc_macid:11_vpn_user:12_allow_email_options:13_allow_change_password:14_allow_piconet:15_allow_antispam:16_cvs_user:17_group:18_in_Bath:19_Picochip_Employee:20_mail_user:21_active_user:22_login_enabled:23_Date_created:24_admin_user
#
 let "i=1"
 while [ $i -le $NUMLINES ]
 do
#
  user=$(cat $TUSERINFO | sed ${i}p -n | awk -F ":" '{print $1}')
  _ADM__GetUserInfo "$user" "$UIFILE"
#
 let "i=i+1"
#
 done
#
# Remove temporary file
#
 rm -f $TUSERINFO
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
#
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
DOALL=0
UIFILE="/home/pcadmin/createuser/etc/user.info"
USERINFOD="/etc"
USERINFOF="user.info"
USERINFO="${USERINFOD}/${USERINFOF}"
TUSERINFO="/tmp/tmp.${USERINFOF}.1.$$.tmp"
#
VERBOSE=0
SENDSTD=1
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$PROGNAME -u username|-a [-f UserInfoFile] [-q] [-v] [-h] [-H] [-V]"
HELPINFO[1]="-f User info file (default /etc/user.info)"
HELPINFO[2]="-u Username"
HELPINFO[3]="-a"
HELPINFO[4]="-v Verbose information"
HELPINFO[5]="-q Quiet output (none to stdio/stderr)"
HELPINFO[6]="-h This help"
HELPINFO[7]="-H Help and examples"
HELPINFO[8]="-V Version"
NUMHELP=8
#
while getopts u:af:qvhHV OPT
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
# DO all
#
	a)
		DOALL=1
	;;
#
# User info file
#
	f)
		UIFILE=$OPTARG
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
# Check do all or a user
#
if [ $DOALL -eq 1 ]
then
 if [ -n "$USERNAME" ]
 then
  _ADM__Log 3 "Either -a or -u not both" 1 $SENDEML 1
  _ADM__Log 1 "$USAGE" 1 $SENDEML 1
  EXITSTAT=1
  _ADM__exit $EXITSTAT
 else
  cat $USERINFO | grep -v "^#" > $TUSERINFO
 fi
else
 if [ -z "$USERNAME" ]
 then
  _ADM__Log 3 "Either -a or -u must be selected" 1 $SENDEML 1
  _ADM__Log 1 "$USAGE" 1 $SENDEML 1
  EXITSTAT=2
  _ADM__exit $EXITSTAT
 else
  for user in $USERNAME
  do
#
   ULINE=$(cat $USERINFO | grep -v "^#" | grep "^${user}:" | tail -n 1)
   echo "$ULINE" >> $TUSERINFO
   if [ -z "$ULINE" ]
   then
    rm -f $TUSERINFO
    _ADM__Log 3 "Username $user is not set up in file $USERINFOF" 1 $SENDEML 1
    _ADM__Log 1 "$USAGE" 1 $SENDEML 1
    EXITSTAT=3
    _ADM__exit $EXITSTAT
   fi
  done
 fi
fi
NUMLINES=`cat $TUSERINFO | wc -l`
#
# Check bounds of UIFILE
#
if [ -z "$UIFILE" ]
then
 _ADM__Log 3 "Filename required" 1 $SENDEML 1
 _ADM__Log 1 "$USAGE" 1 $SENDEML 1
 EXITSTAT=2
 _ADM__exit $EXITSTAT
else
 if [ ! -r "$UIFILE" ]
 then
  _ADM__Log 3 "File $UIFILE does not exist or cannot be opened" 1 $SENDEML 1
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
