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
# Rob Dancer    Added version			1.2     17 Nov 1997
#
# Rob Dancer    References amended to           2.0     01 Dec 1997
#               "admintools"
#
# Rob Dancer    Add options to pass to getops	2.1     19 May 1999
#
# Rob Dancer	Parameter not passed properly	2.2	29 July 1999
#		CSHOST
#
# Rob Dancer	getopts used $2 not $OPTARG	2.3	23 August 1999
#
# Rob Dancer	Updated to bash			2.4	22 June 2006
#
# Rob Dancer    Move definitions to admntools.src	2.5     28 November 2006
#
#
VERSION="2.5, 28 November 2006"
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
# Set up log and temporary comments file
#
DATESTAMP="`date +'%d_%h_%Y_%H:%M:%S'`"
LOGFILE=${ADMINTOOLSLOGS}/configs.${DATESTAMP}.log
TMPFILE="/tmp/config.tmp.$$"
echo "Standard collect info for `date`" > $TMPFILE
#
# Get the system configuration
#
configs -c $TMPFILE -d $CSHOME -h $CSHOST -u $WWWUID -g $WWWGID > $LOGFILE 2>&1
CONFIGSTAT=$?
#
# Delete temporary file if it exists
#
if [ -r "$TMPFILE" ]
then
 rm $TMPFILE
fi
#
#
#
 RETSTAT=$CONFIGSTAT
}

#
# Start here
#
#
# Set up path
#
#PATH=/usr/bin:/usr/ccs/bin:/usr/contrib/bin
#PATH=$PATH:/sbin
#if [ -r /etc/PATH ]
#then
# PATH=$PATH:`cat /etc/PATH`
#fi
# PATH=/usr/sbin:$PATH:/home/root
#export PATH
#
# Source setup file
#
. /etc/admintools.src
SHOWVERSION="FALSE"
#
# Set up user variables
#
CSHOME="/home/configs/hosts"
CSHOST="`hostname`"
WWWUID="root"
WWWGID="sys"
#
# Initialise exits status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$0 [-h host] [-d directory] [-u wwwuid] [-g wwwgid] [-V Version]"
while getopts h:d:u:g:V OPT
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
# Config host
#
	h)
		CSHOST=$OPTARG
	;;
#
# Config directory
#
	d)
		CSHOME=$OPTARG
	;;
#
# Web user id
#
	u)
		WWWUID=$OPTARG
	;;
#
# Web group id
#
	g)
		WWWGID=$OPTARG
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
 _exit 0
fi
#
# Do Main
#
_Main
let "EXITSTAT=EXITSTAT+RETSTAT"
#
# Exit
_exit $EXITSTAT
#
