#!/bin/ksh
#
###########################################################################
#
#     SCCS identifiers
#
#     @(#) modifyuser.ksh 1.5@(#)  09:56:57  97/07/17  /opt/newbridge_setup/HP10.X.SOURCES/addusers/SCCS/s.modifyuser.ksh
#
###########################################################################

export USERNAME=""
export USERUID=""
export USERGID=""
export USERDET=""
export USERDIR=""
export USERSHELL=""
PASSWD="/etc/passwd"

#
# Exit function
_exit () {
 exit $1
}
#
# Useage list
_useage () {
 echo "Useage : modifyuser.ksh [-s enable|disable|modify|delete]"
 echo "                        -s STATUS Script function"
 EXIT_STATUS=8
 _exit $EXIT_STATUS
}


if [ -n "$1" ]
then
 if [ $1 = "-s" ]
 then
  if [ "$2" = "enable" ]
  then
   SCRIPTSTATE="ENABLE"
   SCRIPTDESC="enable/change passwords for user accounts"
  elif [ "$2" = "disable" ]
  then
   SCRIPTSTATE="DISABLE"
   SCRIPTDESC="disable user accounts"
  elif [ "$2" = "modify" ]
  then
   SCRIPTSTATE="MODIFY"
   SCRIPTDESC="change user account details"
  elif [ "$2" = "delete" ]
  then
   SCRIPTSTATE="DELETE"
   SCRIPTDESC="delete user accounts"
  else
   _useage
  fi
 else
  _useage
 fi
else
 SCRIPTSTATE=""
 SCRIPTDESC="modify user accounts"
fi

_line () {
 CHAR=$1
 NUMCOl=$2
 echo $CHAR | awk '{for ( i=0; i<'"$NUMCOL"'; i++ ) { printf "%s",$1}printf "\n"}'
}

_printList () {
 PRINTLIST="$1"
 NUMCHAR=8
 if [ -z "$COLUMNS" ]
 then
  NUMCOL=80
 else
  NUMCOL=$COLUMNS
 fi
 echo
 _line "-" $NUMCOL
 echo "The following users have logins on `hostname` (* means login is disabled)"
 _line "-" $NUMCOL
 echo
 cat $PRINTLIST | awk '{NUMCOL='"$NUMCOL"'; NUMCHAR='"$NUMCHAR"'; currl=0; for (i=1; i<=NF; i++){il=length($i); if (currl+il>NUMCOL){printf "\n";currl=0} printf"%s	", $i;currl=currl+((int(il/NUMCHAR)+1)*NUMCHAR)}}END{printf "\n"}'
 echo
 _line "-" $NUMCOL
 echo
}

_showUserDetails () {
 USERNAME=$1
 USERUID=$2
 USERGID=$3
 USERDET="$4"
 USERDIR=$5
 USERSHELL=$6
 DISPLAYNUM="$7"
#
# Get whether display numbers or not
 MAXNUM=8
 let "NEXTNUM=1"
 let "i=NEXTNUM-1"
 for YN in `echo $DISPLAYNUM | sed -e s/":"/" "/g | awk '{print toupper($0)}'`
 do
#
  DISPTMP="${NEXTNUM})"
#
  if [ "$YN" = "Y" ]
  then
   DISPEXTRA="+"
  else
   DISPEXTRA=" "
  fi
  DISP[$i]="${DISPTMP}${DISPEXTRA}"
  CHANGEVAL[$i]="$DISPEXTRA"
#
  if [ "$NEXTNUM" -eq 4 ]
  then
   let "NEXTNUM=NEXTNUM + 1"
   let "i=NEXTNUM-1"
   DISPTMP="${NEXTNUM})"
   DISP[$i]="${DISPTMP}${DISPEXTRA}"
   CHANGEVAL[$i]="$DISPEXTRA"
   let "NEXTNUM=NEXTNUM + 1"
   let "i=NEXTNUM-1"
   DISPTMP="${NEXTNUM})"
   DISP[$i]="${DISPTMP}${DISPEXTRA}"
   CHANGEVAL[$i]="$DISPEXTRA"
  fi
#
  let "NEXTNUM=NEXTNUM + 1"
  let "i=NEXTNUM-1"
#
 done
#
 echo
 echo "User's details are : "
 echo
 echo "  ${DISP[0]}      Username            : $USERNAME"
 echo "  ${DISP[1]}      UserID              : $USERUID"
 echo "  ${DISP[2]}      GroupID             : $USERGID"
 echo "  ${DISP[3]}      Real name           : `echo $USERDET | cut -d "," -f1`"
 echo "  ${DISP[4]}      Work location       : `echo $USERDET | cut -d "," -f2`"
 echo "  ${DISP[5]}      Telephone number    : `echo $USERDET | cut -d "," -f3`"
 echo "  ${DISP[6]}      User Home Directory : $USERDIR"
 echo "  ${DISP[7]}      User Shell          : $USERSHELL"
 echo
}

_getAnsYN () {
 ANSLOOP="YES"
 while [ "$ANSLOOP" = "YES" ]
 do
  echo "$1"
  echo " (yes/no) : \c"
  read ANS
  case $ANS in
	y|Y|yes|YES)
		STATUS="0"
		ANSLOOP="NO"
	;;
	n|N|no|NO)
		STATUS="1"
		ANSLOOP="NO"
	;;
	*)
		echo "Invalid Answer - yes/no only"
		echo
		ANSLOOP="YES"
	;;
  esac
 done
 return $STATUS
}

_checkUserDetails () {
 _getAnsYN "Is this the right user ?\c"
 return $?
}

_getUserName () {
 echo "Enter username (null username to quit) > \c"
 read USERNAME
}

_getUserUid () {
 USERNAME=$1
 USERUID=`cat $PASSWD | grep "^${USERNAME}:" | cut -d ":" -f3`
}

_getUserGid () {
 USERNAME=$1
 USERGID=`cat $PASSWD | grep "^${USERNAME}:" | cut -d ":" -f4`
}

_getUserDet () {
 USERNAME=$1
 USERDET=`cat $PASSWD | grep "^${USERNAME}:" | cut -d ":" -f5`
}

_getUserDir () {
 USERNAME=$1
 USERDIR=`cat $PASSWD | grep "^${USERNAME}:" | cut -d ":" -f6`
}

_getUserShell () {
 USERNAME=$1
 USERSHELL=`cat $PASSWD | grep "^${USERNAME}:" | cut -d ":" -f7`
}

_checkUserName () {
#
 USERNAME=$1
 USERLIST=$2
#
 MAXLEN=8
 MINLEN=4
 RETSTR[0]="Username OK"
 RETSTR[1]="ERROR : Invalid characters in username use letters and numbers only"
 RETSTR[2]="ERROR : Username too long - must not be greater than $MAXLEN characters"
 RETSTR[3]="ERROR : Username too short - must not be less then $MINLEN characters"
 RETSTR[4]="ERROR : Username should not start with a number"
 RETSTR[5]="ERROR : Username is not in list of valid users"
#
 echo "$USERNAME" | grep "[^0-9^a-z^A-Z]" > /dev/null 2>&1
 if [ $? -eq 0 ]
 then
  RETSTAT=1
 else
  echo "$USERNAME" | grep "^[0-9]" > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   RETSTAT=4
  else
   UNL=`echo $USERNAME | awk '{print length($0)}'`
   if [ "$UNL" -gt "$MAXLEN" ]
   then
    RETSTAT=2
   elif [ "$UNL" -lt "$MINLEN" ]
   then
    RETSTAT=3
   else
    INCLUDELIST=`echo $USERLIST | sed -e s/" "/"$|^"/g -e s/"^"/"^"/ -e s/"$"/"$"/`
    echo $USERNAME | egrep "$INCLUDELIST"
    if [ $? = 0 ]
    then
     RETSTAT=0
    else
     RETSTAT=5
    fi
   fi
  fi
 fi
#
echo ${RETSTR[$RETSTAT]}
return $RETSTAT
#
}

_whichModify () {

echo
echo "     1) Enable/change password for user account"
echo "     2) Disable user account"
echo "     3) Modify user account"
echo "     4) Remove user account"
echo "     q) Quit this menu"
echo
read ANS
case $ANS in
	1)
		MODIFY="ENABLE"
	;;
	2)
		MODIFY="DISABLE"
	;;
	3)
		MODIFY="MODIFY"
	;;
	4)
		MODIFY="DELETE"
	;;
	q)
		MODIFY="QUIT"
	;;
	*)
		echo "Invalid answer"
		MODIFY=""
	;;
esac


}

_modUser () {
 USERNAME=$1
 USERUID=$2
 USERGID=$3
 USERDET="$4"
 USERDIR=$5
 USERSHELL=$6
 USERPASS="*"
 DISPLAYNUM="n:n:n:y:n:n"
#
 USERENTRY[0]=$USERNAME
 USERENTRY[1]=$USERUID
 USERENTRY[2]=$USERGID
 USERENTRY[3]="`echo $USERDET | cut -d "," -f1`"
 USERENTRY[4]="`echo $USERDET | cut -d "," -f2`"
 USERENTRY[5]="`echo $USERDET | cut -d "," -f3`"
 USERENTRY[6]=$USERDIR
 USERENTRY[7]=$USERSHELL
#
 OUSERNAME="$USERNAME"
#
 OUSER[0]="$USERNAME"
 OUSER[1]="$USERUID"
 OUSER[2]="$USERGID"
 OUSER[3]="$USERDET"
 OUSER[4]="$USERDIR"
 OUSER[5]="$USERSHELL"
#
 OPTDET[0]="-l"
 OPTDET[1]="-u"
 OPTDET[2]="-g"
 OPTDET[3]="-c"
 OPTDET[4]="-d"
 OPTDET[5]="-s"
#
#
 set -A CHANGEVAL
 export CHANGEVAL
 MODSTATUS=0
 CHANGED="FALSE"
 MODLOOP="TRUE"
 while [ "$MODLOOP" = "TRUE" ]
 do
#
# Show user's details
  _showUserDetails "$USERNAME" "$USERUID" "$USERGID" "$USERDET" "$USERDIR" "$USERSHELL" "$DISPLAYNUM"
  echo "  0 to make changes permanent"
  echo "  <return> to quit"
  echo
  echo "  + = Modifiable"
  echo
  echo "Enter number of entry to change (1-$MAXNUM) : \c"
  read ENTNUM
  FIRSTCHAR=`echo "$ENTNUM" | awk '{print $0}'`
  FIRSTNUM=`echo "$ENTNUM" | awk '{print int($0)}'`
#
# Check for valid entries
#
# NULL
#
  if [ -z "$ENTNUM" ]
  then
   CHANGED="FALSE"
   MODLOOP="FALSE"
   MODSTATUS=1
#
# Not a number
#
  elif [ "$FIRSTCHAR" != "$FIRSTNUM" ]
  then
   echo "ERROR : Invalid entry"
#
# Out of range
#
  elif [ "$FIRSTNUM" -lt 0 -o "$FIRSTNUM" -gt "$MAXNUM" ]
  then
   echo "ERROR : Number out of range (1-$MAXNUM)"
  else
#
# Finished
#
   if [ "$FIRSTNUM" -eq 0 ]
   then
    MODLOOP="FALSE"
    MODSTATUS=0
   else
    let "NUM=FIRSTNUM-1"
#
# Cannot change entry
#
    if [ "${CHANGEVAL[$NUM]}" = " " ]
    then
     echo "ERROR : Cannot change this entry"
    else
     echo "Enter new value : \c"
     read NEWVAL
#
# Invalid entries for password file
#
     INVALIDCHAR=`echo $NEWVAL | grep "[:@,]"`
     if [ -n "$INVALIDCHAR" ]
     then
      echo "ERROR : Invalid characters in entry"
     else
#
      USERENTRY[$NUM]="$NEWVAL"
#
      USERNAME=${USERENTRY[0]}
      USERUID=${USERENTRY[1]}
      USERGID=${USERENTRY[2]}
      USERDET="${USERENTRY[3]},${USERENTRY[4]},${USERENTRY[5]}"
      USERDIR=${USERENTRY[6]}
      USERSHELL=${USERENTRY[7]}
#
      CHANGED="TRUE"
#
     fi
#
    fi
#
   fi
#
  fi
 done
#
 NUSER[0]="$USERNAME"
 NUSER[1]="$USERUID"
 NUSER[2]="$USERGID"
 NUSER[3]="$USERDET"
 NUSER[4]="$USERDIR"
 NUSER[5]="$USERSHELL"
#
 CHECKCHANGED="FALSE"
 i=0
 while [ $i -lt 6 ]
 do
  if [ "${OUSER[$i]}" != "${NUSER[$i]}" ]
  then
   OPTUSER[$i]="${OPTDET[$i]} \"${NUSER[$i]}\""
   CHECKCHANGED="TRUE"
  fi
  let "i=i+1"
 done
#
 if [ "$CHANGED" = "TRUE" ]
 then
  if [ "$CHECKCHANGED" = "TRUE" ]
  then
   echo
   echo "Making changes to user entry $OUSERNAME"
   echo
   OPTIONS="${OPTUSER[0]} ${OPTUSER[1]} ${OPTUSER[2]} ${OPTUSER[3]} ${OPTUSER[4]} ${OPTUSER[5]}"
   eval /usr/sbin/usermod $OPTIONS $OUSERNAME
   MODSTATUS=$?
  else
   echo "No modifications have been made"
   MODSTATUS=0
  fi
 fi
#
return $MODSTATUS
#
}

_disableUser () {
 USERNAME=$1
#
# Set up return statuses
#
 RETSTR[0]=""
 RETSTR[1]="ERROR : Temporary password file exists. Call Unix support"
 RETSTR[2]="ERROR : Temporary password file does not exist. Call Unix support"
 RETSTR[3]="ERROR : Cannot copy new password file. Call Unix support"
 RETSTR[4]="ERROR : Cannot create temporary password file. Call Unix support"

 TMPPWFILE="/tmp/passwd.$$"
 if [ -n $TMPPWFILE ]
 then
  if [ -f $TMPPWFILE ]
  then
   RETSTAT=1
  else
   cat $PASSWD | sed -e /"^${USERNAME}:"/s/"^\([^:]*\):[^:]*:"/"\1:*:"/ > $TMPPWFILE
   if [ $? = 0 ]
   then
    cp $TMPPWFILE $PASSWD
    if [ $? = 0 ]
    then
     rm -f $TMPPWFILE
     RETSTAT=0
    else
     RETSTAT=3
    fi
   else
    RETSTAT=4
   fi
  fi
 else
  RETSTAT=2
 fi

#
echo "${RETSTR[$RETSTAT]}"
return $RETSTAT
#
}

_enableUser () {
USERNAME=$1
/usr/bin/passwd $USERNAME
}

_remUser () {
USERNAME=$1
_getAnsYN "Are you sure you want to remove this user ?\c"
if [ $? -eq 0 ]
then
 /usr/sbin/userdel -r $USERNAME
 REMSTAT=$?
else
 REMSTAT=1
fi
#
return $REMSTAT
#
}


#
#
# Start here
#
#
# Useage list
EXCLUDE="root|daemon|bin|sys|adm|uucp|lp|nuucp|hpdb|nobody"
#
# Set up exit status
EXIT_STATUS=0
#

MODUSERNAME="TRUE"
while [ "$MODUSERNAME" = "TRUE" ]
do

# Get a list of users on the system
 EXCLUDELIST=`echo $EXCLUDE | sed -e s/"|"/":|^"/g -e s/"^"/"^"/ -e s/"$"/":"/`
 TMPPWUSERLIST="/tmp/tmppwuserlist.$$"
 cat $PASSWD | cut -d ":" -f1,2 | sort -t ":" -k 1,1 | egrep -v $EXCLUDELIST | sed -e /:*/s/":\*"/"\*"/ -e s/":.*"/""/ > $TMPPWUSERLIST
#
 USERLIST=`cat $TMPPWUSERLIST | sed -e s/"\*"/""/g`
#
 clear
 echo
 echo "This program will $SCRIPTDESC on `hostname`"
 echo
# Print a list of users with processes in a nice format
 _printList "$TMPPWUSERLIST"
 rm $TMPPWUSERLIST
#

 _getUserName

 if [ -z "$USERNAME" ]
 then
  MODUSERNAME="FALSE"
 else
  _checkUserName "$USERNAME" "$USERLIST"
  if [ $? = 0 ]
  then
   _getUserDir $USERNAME
   _getUserUid $USERNAME
   _getUserGid $USERNAME
   _getUserDet $USERNAME
   _getUserShell $USERNAME
   _showUserDetails "$USERNAME" "$USERUID" "$USERGID" "$USERDET" "$USERDIR" "$USERSHELL" "n:n:n:n:n:n"
   echo
   _checkUserDetails
   if [ $? -eq "0" ]
   then
    export MODIFY=""
    if [ -z "$SCRIPTSTATE" ]
    then
     _whichModify
    else
     MODIFY="$SCRIPTSTATE"
    fi
    case $MODIFY in
	ENABLE)
		_enableUser "$USERNAME"
		MODSTAT=$?
		;;
	DISABLE)
		_disableUser "$USERNAME"
		MODSTAT=$?
		;;
	DELETE)
		_remUser "$USERNAME"
		MODSTAT=$?
		;;
	MODIFY)
		_modUser "$USERNAME" "$USERUID" "$USERGID" "$USERDET" "$USERDIR" "$USERSHELL"
		MODSTAT=$?
		;;
	QUIT)
		MODSTAT=0
		;;
	*)
		MODSTAT=1
		;;
    esac

    if [ "$MODSTAT" -eq 0 ]
    then
     echo
    else
     echo "WARNING : User not modified"
    fi
#
    echo "Press <return> to continue"
    read ANS
#
   else
    echo "Re-enter user's details"
   fi
  fi
 fi

done


