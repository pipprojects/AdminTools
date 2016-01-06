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
VERSION="2.4, 23 Apr 1998"
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
OPTION=""
FILE=""
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$0 [-o option] [-f file] [-V Version]"
while getopts of:V OPT
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
# Option
#
	o)
		OPTION=$OPTARG
	;;
#
# File
#
	f)
		FILE=$OPTARG
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
# Check bounds of OPTION
#
if [ -z "$OPTION" ]
then
 echo "ERROR : Invalid option - $OPTION"
 _exit 1
else
 OPTION=$OPTION
fi
#
# Check bounds of FILE
#
if [ -z "$FILE" ]
then
 echo "ERROR : Filename required"
 echo "$USAGE"
 EXITSTAT=2
 _exit $EXITSTAT
else
 if [ ! -r "$FILE" ]
 then
  echo "ERROR : File $FILE does not exist or cannot be opened"
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
