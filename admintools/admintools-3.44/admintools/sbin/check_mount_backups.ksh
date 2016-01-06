#!/bin/ksh
#
hostname="$(hostname)"
NUMOPT=2
OPTS[1]="access"
OPTS[2]="root"
#
for entry in `cat /etc/fstab | grep -v "^#" | awk '{if ( $3 !~ "swap"  ){print $2}}'`
do
 LINE="$(grep "^${entry}[	 ]" /etc/exports)"
 if [ -z "$LINE" ]
 then
  echo "WARNING : Mounted filesystem $entry is not in /etc/exports"
 else
#
  i=1
  while [ i -le $NUMOPT ]
  do
   OS[$i]=0
   let "i=i+1"
  done
#
  for option in `echo $LINE | awk '{print $2}' | sed -e s/","/" "/g`
  do
#
   opt=$(echo "$option" | sed -e s/"^-"/""/g | sed -e s/"=.*"/""/g)
   par=$(echo "$option" | sed -e s/".*="/""/g | sed -e s/":"/" "/g)
#
   i=1
   while [ i -le $NUMOPT ]
   do
    OPTSET="${OPTS[$i]}"
#
    if [ $opt = "$OPTSET" ]
    then
#
     for param in $par
     do
#
      if [ $param = $hostname ]
      then
       OS[$i]=1
#
      fi
#
     done
#
    fi
#
    let "i=i+1"
   done
#
  done
#
  SRCFILE="/opt/orange/etc/backup.src"
  NOB=$(grep "NumberOfBackups=" $SRCFILE)
  if [ -n "$NOB" ]
  then
   eval $NOB
   NOB="$NumberOfBackups"
  else
   echo "ERROR : $SRCFILE invalid"
   exit 1
  fi
#
  nb=1
  while [ $nb -le $NOB ]
  do
   FILE="/opt/admintools/etc/backup_${nb}.list"
#
   backup_entry=$(grep "[	 ]${entry}$" $FILE)
   if [ -z "$backup_entry" ]
   then
    echo "WARNING : Mounted filesystem $entry is not in $FILE"
   fi
#
   let "nb=nb+1"
#
  done
#
  i=1
  while [ i -le $NUMOPT ]
  do
   if [ OS[$i] -eq 0 ]
   then
    echo "WARNING : Option ${OPTS[$i]} not set for $entry"
   else
    echo "INFO : Option ${OPTS[$i]} is set for $entry"
   fi
   let "i=i+1"
  done
#
 fi
#
done
#
