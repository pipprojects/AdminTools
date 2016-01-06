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
# Rob Dancer    bdf.ksh				3.0	13 Sep 1999
#		Returns mounted filesystems on one line
#
# Rob Dancer    Change for Linux		3.1	08 July 2002
#
VERSION="3.1, 08 July 2002"
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
if [ $HOSTTYPE = "HP" ]
then
 COMMAND="bdf"
else
 COMMAND="df -k"
fi
#
$COMMAND $BDFOPTIONS | awk 'BEGIN{num=0
		 MFD=6
		 for (i=1; i<=MFD; i++){
		  MLEN[i]=0
		 }
		 NUMREC=0
		 SPACES="                "
		 RECJUST[1]="-"
		 RECJUST[2]=""
		 RECJUST[3]=""
		 RECJUST[4]=""
		 RECJUST[5]=""
		 RECJUST[6]="-"
		}{
		  MAX=MFD
		  if ( NF > MAX ){
		   NFIELDS=MAX
		  } else {
		   NFIELDS=NF
		  }
		  for (i=1; i<=NFIELDS; i++){
		   num=num+1
		   if ( num == 1 ){
		    NUMREC=NUMREC+1
		   }
		   LEN[num]=length($i)
		   if ( LEN[num] > MLEN[num] ){
		    MLEN[num]=LEN[num]
		   }
		   if (num == 1){
		    LINE[NUMREC]=$i
		   }else{
		    LINE[NUMREC]=LINE[NUMREC] " " $i
		   }
		   if (num == MAX){
		    LINE[NUMREC]=LINE[NUMREC] " "
		    num=0
		   }
		  }
		}END{
		 for (i=1; i<=NUMREC; i++){
		  REST=LINE[i]
		  for (n=1; n<=MFD; n++){
		   PART=REST
		   I=index(PART," ")
		   SECTION=substr(PART,1,I-1)
		   REST=substr(PART,I+1)
		   NUMSP=MLEN[n]
		   JUST=RECJUST[n]
		   REC=sprintf ("%"JUST NUMSP"s",SECTION)
		   if ( n == 1 ){
		    RECORD=REC
		   } else {
		    RECORD=RECORD " " REC
		   }
		  }
		   printf "%s\n",RECORD
		 }
		}'
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
USAGE="$0 [bdf options] [-V Version]"
while getopts V OPT
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
# Set up bdf options
#
BDFOPTIONS="$*"
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
