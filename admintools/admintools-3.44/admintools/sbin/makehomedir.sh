#!/bin/bash
#
userinfo=$(ypcat passwd | cut -d ":" -f1,4)
for user in $userinfo
do
 username=$(echo $user | cut -d ":" -f1)
 groupid=$(echo $user | cut -d ":" -f2)
 echo "User: $username"
 HOMEDIR="/export/home/${username}"
 if [ ! -d $HOMEDIR ]
 then
  echo "Making home directory $HOMEDIR"
  mkdir $HOMEDIR
 fi
 chown ${username}:${groupid} /export/home/${username}
done
#
