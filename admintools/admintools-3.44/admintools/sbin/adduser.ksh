#!/bin/ksh
#
###########################################################################
#
#     SCCS identifiers
#
#     @(#) adduser.ksh 1.10@(#)  11:42:14  97/07/30  /opt/newbridge_setup/HP10.X.SOURCES/addusers/SCCS/s.adduser.ksh
#
###########################################################################

export USERNAME=""
export USERUID=""
export USERGID=""
export USERDET=""
export USERDIR=""
export USERSHELL=""
export USEREMAIL=""
PASSWD="/etc/passwd"

#
# Exit function
_exit () {
 exit $1
}

_showUserDetails () {
 USERNAME=$1
 USERUID=$2
 USERGID=$3
 USERDET="$4"
 USERDIR=$5
 USERSHELL=$6

 echo
 echo "User's details are : "
#
 echo
 echo "        Username         : $USERNAME"
 echo "        Real name        : `echo $USERDET | cut -d "," -f1`"
 echo "        Work location    : `echo $USERDET | cut -d "," -f2`"
 echo "        Telephone number : `echo $USERDET | cut -d "," -f3`"
 echo
#
}

_getAnsYN () {
 ANSLOOP="YES"
 while [ "$ANSLOOP" = "YES" ]
 do
  echo "$1"
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
 _getAnsYN "Details OK ? (yes/no) > \c"
 return $?
}

_getUserName () {
 echo
 echo "Enter username (null username to quit) > \c"
 read USERNAME
}

_getUserUid () {
 LASTUID=`cat $PASSWD | sort -t ":" -n -k 3 | cut -d ":" -f 3 | tail -1`
 let "USERUID=LASTUID + 1"
}

_getUserGid () {
 USERGID="101"
}

_getUserDir () {
 USERDIR="/usr/$USERNAME"
}

_getUserDet () {
 echo "Enter user's fullname (Firstname Lastname) > \c"
 read URN
 echo "Enter user's office location > \c"
 read UOL
 echo "Enter user's work number > \c"
 read UWN
 USERDET="$URN,$UOL,$UWN,"
 USEREMAIL=`echo $URN | sed -e s/"[	 ]"/"_"/`
}

_getUserShell () {
 USERSHELL="/usr/bin/sh"
}

_checkUserName () {
#
 USERNAME=$1
#
 MAXLEN=8
 MINLEN=4
 RETSTR[0]="Username OK"
 RETSTR[1]="ERROR : Invalid characters in username use letters and numbers only"
 RETSTR[2]="ERROR : Username too long - must not be greater than $MAXLEN characters"
 RETSTR[3]="ERROR : Username too short - must not be less then $MINLEN characters"
 RETSTR[4]="ERROR : Username should not start with a number"
 RETSTR[5]="ERROR : Username already exists"
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
    grep -q "^${USERNAME}:" $PASSWD
    if [ $? = 0 ]
    then
     RETSTAT=5
    else
     RETSTAT=0
    fi
   fi
  fi
 fi
#
echo ${RETSTR[$RETSTAT]}
return $RETSTAT
#
}

#
#
# Start here
#

ADDUSERNAME="TRUE"
while [ "$ADDUSERNAME" = "TRUE" ]
do

 STATUS=0

 _getUserName

 if [ -z "$USERNAME" ]
 then
  ADDUSERNAME="FALSE"
 else
  _checkUserName "$USERNAME"
  if [ $? = 0 ]
  then
   _getUserDir
   _getUserUid
   _getUserGid
   _getUserDet
   _getUserShell
   _showUserDetails "$USERNAME" "$USERUID" "$USERGID" "$USERDET" "$USERDIR" "$USERSHELL"
   _checkUserDetails
   if [ $? -eq "0" ]
   then
    SKELDIR="/etc/skel"
    /usr/sbin/useradd -u $USERUID -g $USERGID -d $USERDIR -c "$USERDET" -k $SKELDIR -m -s $USERSHELL $USERNAME
    if [ $? -eq 0 ]
    then
#
     echo "User added"
# Go to user's home directory to change .profile
     cd $USERDIR
# Check where we are!!
     if [ "`ls -ond . | awk '{print $3}'`" = "$USERUID" ]
     then
      if [ "`ls -gnd . | awk '{print $3}'`" = "$USERGID" ]
      then
#
# We are in the right place!!
# Create link for user's .profile
       rm -f .profile > /dev/null 2>&1
       ln -s $SKELDIR/hp.profile $USERDIR/.profile
# Create .forward so email is sent to correct place
       echo "${USEREMAIL}@qmail" > .forward
       chown ${USERUID}:${USERGID} .forward
# Set password for user
       /usr/bin/passwd $USERNAME
# Exclude from ftp
       #echo $USERNAME >> /etc/ftpusers
#
      else
       echo "WARNING : Home directory has wrong group - Check with Unix support"
       STATUS=4
      fi
     else
      echo "WARNING : .profile has wrong owner - Check with Unix support"
      STATUS=3
     fi
#
    else
     echo "ERROR : User not added"
     STATUS=1
    fi
   else
    echo "Re-enter user's details"
    STATUS=2
   fi
  fi
 fi

done

echo

_exit $STATUS


