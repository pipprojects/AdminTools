#!/bin/ksh
#
#*****************************************************************************
#
# Name          Description                     Version Date
#
# Rob Dancer    Initial version                 1.0     14 Nov 1997
#
# Rob Dancer    Added error conditions		1.1     14 Nov 1997
#
# Rob Dancer    References amended to           2.0     01 Dec 1997
#               "admintools"
#
# Rob Dancer    Change -o so other options	2.1     15 Jan 1998
#		can be passed to backuplvs
#
# Rob Dancer    Added -m option			2.2     15 Jan 1998
#
# Rob Dancer    When calling backuplvs make	2.3	06 Jan 1999
#		sur -M option is "n"
#
# Rob Dancer    sysbackup_remote_host.ksh	3.0	14 Sep 1999
#
VERSION="14 Sep 1999"
#
#*****************************************************************************
#
# Exit function
#
function _exit {
 exit $1
}
#
function _backupFiles {
#
# Set up backup variables
#
DATESTAMP="`date +'%d_%h_%Y_%H:%M:%S'`"
MARK="${BACKUPNUM}_${DATESTAMP}"
LOGFILE="${ADMINTOOLSLOGS}/sysbackup_${MARK}.log"
GRAPH="${ADMINTOOLSETC}/backup_${BACKUPNUM}.list"
CONFILE="${ADMINTOOLSLOGS}/backup_${MARK}.conf"
#
cd $ADMINTOOLSLOGS
# echo "fbackup -f $TAPEDEV -I $ADMINTOOLSLOGS -v -0 -l -n  -i /sekonda > $LOGFILE 2>&1"
# echo "fbackup -f /dev/rmt/1m -I $CONFILE -v -0 -l -n  -i /sekonda -i /swatch > $LOGFILE 2>&1"
echo "fbackup -f $TAPEDEV -I $CONFILE -v -0 -l -n $BACKUPLIST $OPTION > $LOGFILE 2>&1"
fbackup -f $TAPEDEV -I $CONFILE -v -0 -l -n $BACKUPLIST $OPTION > $LOGFILE 2>&1
#echo "backuplvs $OPTION -f $CONFILE -l $ADMINTOOLSLOGS -u $MARK -t $TAPEDEV -g $GRAPH -M n > $LOGFILE 2>&1"
#backuplvs $OPTION -f $CONFILE -l $ADMINTOOLSLOGS -u $MARK -t $TAPEDEV -g $GRAPH -M n > $LOGFILE 2>&1
if [ $? = 0 ]
then
 checkeject $TAPEDEV >> $LOGFILE 2>&1
 RETSTAT=0
else
 echo "Problem with backuplvs - tape not ejected" >> $LOGFILE 2>&1
 RETSTAT=1
fi
#
#
#
}
#
# Start here
#
#
# Source setup file
#
. /etc/admintools.src
#
# Default tape device
#
TAPEDEV="/dev/rmt/0m"
#
# Default option for backuplvs
#
OPTION=""
MIRDIR=""
#
# Default backup number
#
BACKUPNUM="1"
#
# Get command line options
#
USAGE="$0 [-o fbackup_options] [-m mount_dir] [-t tape_device] [-n backup_number] [-V Version]"
#
while getopts m:o:t:n:V OPT
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
# Option to pass to backuplvs
#
        o)
                OPTION=$2
        ;;
#
# Specify mount directory
#
        m)
                MIRDIR="$2"     
		OPTION="$OPTION -m $MIRDIR"
        ;;
#
# tape device
#
        t)
                TAPEDEV=$2
        ;;
#
# backup number
#
        n)
                BACKUPNUM=$2
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
# Do main function
#
_backupFiles
let "EXITSTAT=RETSTAT"
#
# Send error message
#
if [ "$EXITSTAT" -eq 0 ]
then
 echo "Backup completed at `date`" >> $LOGFILE
else
 echo "Backup error condition at `date`" >> $LOGFILE
fi
#
# Exit with status
#
_exit $EXITSTAT
#
