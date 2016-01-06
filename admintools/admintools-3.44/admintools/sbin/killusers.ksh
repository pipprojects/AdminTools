#!/bin/ksh
###########################################################################
#
#     SCCS identifiers
#
#     @(#) killusers.ksh 1.7@(#)  13:34:32  97/11/06  /opt/newbridge_setup/HP10.X.SOURCES/killusers/SCCS/s.killusers.ksh
#
###########################################################################
#
# This script will kill processes and child processes (from the bottom up
# to avoid defunct and rogue processes) of any user apart
# from those in the EXCLUDE variable list (separated by | )
#

#
# Exit function
_exit () {
 exit $1
}
#
# Useage list
_useage () {
 echo "Useage : killusers.ksh [-s SHELL]"
 echo "                        -s SHELL   Shell or program to kill"
 EXIT_STATUS=8
 _exit $EXIT_STATUS
}
#
KILLSHELL="FALSE"
if [ -n "$1" ]
then
 if [ "$1" = "-s" ]
 then
  KILLSHELL="TRUE"
  if [ -n "$2" ]
  then
   SHELLTYPE="$2"
  else
   SHELLTYPE="sh"
  fi
 else
  _useage
 fi
fi
#
EXCLUDE="UID|root|lp|ftp|bin|daemon"
#
# Set up exit status
EXIT_STATUS=0
#
# Get a list of users on the system with pattern matching characters
EXCLUDELIST=`echo $EXCLUDE | sed -e s/"|"/"$|^"/g -e s/"^"/"^"/ -e s/"$"/"$"/`
USERLIST=`ps -ef | awk '{print $1}' | sort -u | egrep -v "$EXCLUDELIST"`
#
# Print a list of users with processes in a nice format
if [ -z "$COLUMNS" ]
then
 NUMCOL=80
else
 NUMCOL=$COLUMNS
fi
clear
echo
echo "-" | awk '{for ( i=0; i<'"$NUMCOL"'; i++ ) { printf "%s",$1}printf "\n"}'
echo "The following users have processes on `hostname`"
echo "-" | awk '{for ( i=0; i<'"$NUMCOL"'; i++ ) { printf "%s",$1}printf "\n"}'
echo
echo $USERLIST | awk '{NUMCOL='"$NUMCOL"'; currl=0; for (i=1; i<=NF; i++){il=length($i); if (currl+il>NUMCOL){printf "\n";currl=0} printf"%s	", $i;currl=currl+((int(il/8)+1)*8)}printf "\n"}'

echo
echo "-" | awk '{for ( i=0; i<'"$NUMCOL"'; i++ ) { printf "%s",$1}printf "\n"}'
echo
#
echo "Enter username (<return> to quit) : \c"
read USERNAME
#
# Check for null username
if [ -z "$USERNAME" ]
then
 echo "No processes killed"
 EXIT_STATUS=1
 _exit $EXIT_STATUS
fi
# Check if user in list
USEROK="FALSE"
for user in $USERLIST
do
 if [ "$USERNAME" = "${user}" ]
 then
  USEROK="TRUE"
 fi
done
#
echo
#
if [ "$USEROK" = "TRUE" ]
then
#
# Check to see if need to prompt
 if [ "$KILLSHELL" = "FALSE" ]
 then
  ps -fu${USERNAME}
  PID1=`ps -fu${USERNAME} | awk '{print $2}' | grep "^[0-9]"`
  echo
  echo "Enter PID of process to kill (Empty string will quit)"
  read PROCIDS
 else
  #
  #ps -u${USERNAME} | awk '{if ( $4 ~ "^'"$SHELLTYPE"'$" ) print $0}'
  PID1=`ps -u${USERNAME} | awk '{if ( $4 ~ "^'"$SHELLTYPE"'$" ) print $1}' | grep "^[0-9]"`
  PROCIDS="$PID1"
 fi
#
#>
 if [ -n "$PROCIDS" ]
 then
  PROCLIST=`echo $PROCIDS | grep -v "[^0-9 ]"`
#->
  if [ -n "$PROCLIST" ]
  then
   NUMPROC=`echo $PROCIDS | wc -w`
# Check to see if process is valid
   PROCBADLST=""
   for PROCID in $PROCIDS
   do
    PROCOK="FALSE"
    for pid in $PID1
    do
     if [ "$PROCID" = "$pid" ]
     then
      PROCOK="TRUE"
     fi
    done
    if [ "$PROCOK" != "TRUE" ]
    then
     PROCBADLST="$PROCBADLST $PROCID"
    fi
   done
# If process is valid then go and get all child processes
#-->
   if [ -z "$PROCBADLST" ]
   then
    let "ncpid=0"
    for PROCID in $PROCIDS
    do
     CPIDS[$ncpid]=`ps -ef | awk '{if ( $2 == "'"$PROCID"'" ) print $2}'`
    done
    CHECKPID=${CPIDS[$ncpid]}
    let "ncpid=ncpid+1"
    let "nextcpid=0"
    let "nextcpid=nextcpid+1"
    LOOP="TRUE"
#
#--->
    while [ "$LOOP" = "TRUE" ]
    do
     for procid in $CHECKPID
     do
      CPIDS[$ncpid]=`ps -ef | awk '{if ( $3 == "'"$procid"'" ) print $2}'`
      if [ -n "${CPIDS[$ncpid]}" ]
      then
       let "ncpid=ncpid+1"
      fi
     done
     CHECKPID=${CPIDS[$nextcpid]}
     let "nextcpid=nextcpid+1"
     if [ "$nextcpid" -gt "$ncpid" ]
     then
      LOOP="FALSE"
     fi
    done
#---<
#
# ncpid now has the number of arrays containing process ids
    echo
    echo "The following processes will be killed!!!!"
#
# Loop round and print processes ids
# Print the header
    ps -ef | awk '{if ( $1 == "UID" ) print $0}'
    let "count=0"
#--->
    while [ "$count" -lt "$ncpid" ]
    do
     for pid in ${CPIDS[$count]}
     do
      ps -ef | awk '{if ( $2 == "'"$pid"'" ) print $0}'
     done
     let "count=count+1"
    done
#---<
#
    echo
    echo "Enter yes to confirm (anything else quits)"
    read ANS
    case $ANS in
	yes)
# Loop round and kill processes
		let "count=ncpid-1"
		while [ "$count" -ge 0 ]
		do
		 for pid in ${CPIDS[$count]}
		 do
		  echo "kill $pid"
		  kill $pid
		 done
		 let "count=count-1"
		done
		let "count=ncpid-1"
# Check to see if processes have been killed
		TMPNOKILL="/tmp/kill_nokill.$$"
		touch $TMPNOKILL
		rm -f $TMPNOKILL
		while [ "$count" -ge 0 ]
		do
		 for pid in ${CPIDS[$count]}
		 do
		  ps -ef | awk '{if ( $2 == "'"$pid"'" ) print '"$pid"'}' >> $TMPNOKILL
		 done
		 let "count=count-1"
		done
		if [ -f $TMPNOKILL ]
		then
		 for pid in `cat $TMPNOKILL`
		 do
		  echo "Warning : Process $pid has not been killed"
		  echo "Use 'Extreme Force' (only yes will work)? \c"
		  read ANS
		  case $ANS in
			yes) echo "kill -9 $pid"
			     kill -9 $pid
			     sleep 1
			     pidC=`ps -ef | awk '{if ($2 == "'"$pid"'") print $2}'`
			     if [ -n "$pidC" ]
			     then
			      echo "ERROR : Process $pid not killed. Call Unix support"
			      EXIT_STATUS=7
			     else
			      echo "Process killed"
			     fi
			;;
			*) echo "Process $pid not killed"
			   EXIT_STATUS=6
			;;
		  esac
		 done
		 rm -f $TMPNOKILL
		else
		 echo "All required processes have been killed"
		fi
	;;
	*) echo "No processes killed"
	   EXIT_STATUS=5
	;;
    esac
#-->
   else
    echo "ERROR : PID '$PROCBADLST' not valid process(es) for this user"
    EXIT_STATUS=4
   fi
#-->
  else
   echo "Only enter PID's separated by spaces NOT commas"
   EXIT_STATUS=9
  fi
#->
 else
  echo "No processes killed"
  EXIT_STATUS=2
 fi
#>
else
 echo "ERROR : Username '$USERNAME' not valid"
 EXIT_STATUS=3
fi
#

_exit $EXIT_STATUS
 
