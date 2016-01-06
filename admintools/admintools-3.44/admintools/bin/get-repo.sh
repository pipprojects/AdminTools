#!/bin/bash
#
#*****************************************************************************
#
# Name          Description                     	Version Date
#
# Rob Dancer    Template Version taken from 		1.0	2 Dec 2004
#		genPicoLicence.sh
#
# Rob Dancer    Move definitions to admntools.src	1.1     28 November 2006
#
# Rob Dancer	Change !Quite" to "Quiet"		1.2	11 April 2007
#
# Rob Dancer	Add admfunctions.src			1.3	11 May 2007
#
# Rob dancer	Make sure uses _ADM__Log not _Log	1.4	4 June 2007
#
# Rob Dancer	1.5	2 October 2007
# amend -f and -o options
#
# Rob Dancer	1.0	22 February 2008
# get-repo.sh
#
#
VERSION="1.0, 22 February 2008"
#
#*****************************************************************************
#
function _GetRepo_CheckList {
 TEST="$1"
 TESTS="$2"
 MESSAGE="$3"
 SETEXITSTAT="$4"
#
 SETTEST=""
 if [ -n "${TEST}" ]
 then
  for test in $TESTS
  do
   if [ "${test}" = "${TEST}" ]
   then
    SETTEST="${test}"
   fi
  done
 fi
 if [ -z "${SETTEST}" ]
 then
  _ADM__Log 3 "${MESSAGE}" 1 $SENDEML 1
  _ADM__Log 1 "$USAGE" 1 $SENDEML 1
  EXITSTAT=$SETEXITSTAT
  _ADM__exit $EXITSTAT
 fi
}
#
# Main function
#
function _Main {
#
# Insert user function here
#
#
#
 MVER=$(echo $VER | cut -d "." -f1)
 case $MVER in
	3) DISTRO="RedHat"
	   RPMDIR="RPMS"
	   DL=""
	;;
	4) DISTRO="CentOS"
	   RPMDIR="RPMS"
	   DL=""
	;;
	5) DISTRO="CentOS"
	   RPMDIR=""
	   DL="-"
	;;
	*) DISTRO="CentOS"
	   RPMDIR=""
	   DL="-"
	;;
 esac
#
 case $TYPE in
	os)	PATHVER="${VER}/${TYPE}/${ARCH}/${DISTRO}/${RPMDIR}"
		let NUMDISK="1"
	;;
	isos|torrent)
			case $MEDIA in
				DVD) let "NUMDISK=1"
				;;
				*)
				;;
			esac
			PATHVER="${VER}/${TYPE}/${ARCH}"
			FILENAME="CentOS-${VER}-${ARCH}-bin${DL}1of"
			FILENAMEM="CentOS-${MVER}\.*[0-9]*-${ARCH}-bin${DL}1of"
			if [ $NUMDISK -eq 0 ]
			then
			 URL="${PROT}://${HOST}/${UPATH}/${PATHVER}/${FILENAME}"
			 INDFILE="index.html"
			 rm -f $INDFILE
			 echo "wget "http://${HOST}/${UPATH}/${PATHVER}""
			 wget "http://${HOST}/${UPATH}/${PATHVER}"
			 NAME=$(basename `cat $INDFILE | sed -e /"${FILENAMEM}[0-9]\{1,\}.iso\""/s/".*<A .*HREF=\"\([^>]\{1,\}${FILENAMEM}[0-9]\{1,\}.iso\)\">.*"/"\1"/gp -n`)
			 FILENAMEPRE="$(echo $NAME | sed -e s/"\(^.*bin${DL}\)[0-9]\{1,\}of.*.iso"/"\1"/g)"
			 NUMDISK="$(echo $NAME | sed -e s/"^.*of\([0-9]\{1,\}\).iso"/"\1"/g)"
			fi
	;;
 esac
#
 case $PROT in
	rsync)
		DESTDIR="${DDIR}/${PATHVER}"
		PATHVER="${PATHVER}/"
		if [ ! -d "$DESTDIR" ]
		then
		 mkdir -p $DESTDIR
		fi
	;;
	*)
		DESTDIR=""
	;;
 esac
#
 let "i=1"
 while [ $i -le $NUMDISK ]
 do
  FILENAME=""
  case $TYPE in
	isos)
		COMOPT=""
 		case $MEDIA in
			CD)
#			FILENAME="CentOS-${VER}-${ARCH}-bin${DL}${i}of${NUMDISK}.iso"
			FILENAME="${FILENAMEPRE}${i}of${NUMDISK}.iso"
			;;
			DVD)
			FILENAME="CentOS-${VER}-${ARCH}-bin${DL}DVD.iso"
			;;
		esac
	;;
	torrent) FILENAME="CentOS-${VER}-${ARCH}-bin-DVD.torrent"
	;;
	*) FILENAME=""
	;;
  esac
  URL="${PROT}://${HOST}/${UPATH}/${PATHVER}/${FILENAME}"
  _ADM__Log 0 "$COM $COMOPT $URL $DESTDIR" 1 $SENDEML 1
  if [ $TESTGO = "FALSE" ]
  then
   $COM $COMOPT $URL $DESTDIR
#
# Create repo
#
   if [ -n "${FILENAME}" ]
   then
    _ADM__Log 0 "Creating repository" 1 $SENDEML 1
    createrepo -q -c /var/www/cache $DDIR
   fi
  fi
#
  let "i=i+1"
#
 done
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
VER=""
ARCHES="i386 x86_64 noarch"
ARCH=$(echo $ARCHES | awk '{print $1}')
let NUMDISK="0"
MEDIAS="DVD CD"
MEDIA=$(echo $MEDIAS | awk '{print $1}')
PROTS="rsync http ftp"
PROT=$(echo $PROTS | awk '{print $1}')
HOST="www.mirrorservice.org"
UPATH="sites/mirror.centos.org"
TYPES="isos os torrent"
TYPE=$(echo $TYPES | awk '{print $1}')
ADIR="$PWD"
DDIR="centos"
TESTGO="FALSE"
COM="wget"
COMOPT=""
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
USAGE="$PROGNAME -r Release [-a Architecture] [-n NumberOfDisks] [-m Media] [-p Protocol] [-s Host] [-P Path] [-t Type] [-c] [-d RelativeDestinationDirectory] [-D AbsoluteDestiantionDirectory] [-q] [-v] [-h] [-H] [-V]"
HELPINFO[1]="-r Release (4, 4.6, 5 etc)"
HELPINFO[2]="-a Architecture [${ARCH}] (${ARCHES})"
HELPINFO[3]="-n Number of Disks [${NUMDISK}]"
HELPINFO[4]="-m Media [${MEDIA}] (${MEDIAS})"
HELPINFO[5]="-p Protocol [${PROT}] (${PROTS})"
HELPINFO[6]="-s Host [${HOST}]"
HELPINFO[7]="-P Path [${UPATH}]"
HELPINFO[8]="-t Type [${TYPE}] (${TYPES})"
HELPINFO[9]="-c Check path - Do not get files [${TESTGO}]"
HELPINFO[10]="-d Relative destination directory [${DDIR}]"
HELPINFO[11]="-D Absolute Destination directory [${ADIR}]"
HELPINFO[12]="-v Verbose information"
HELPINFO[13]="-q Quiet output (none to stdio/stderr)"
HELPINFO[14]="-h This help"
HELPINFO[15]="-H Help and examples"
HELPINFO[16]="-V Version"
NUMHELP=16
#
while getopts r:a:n:m:p:s:P:t:cd:D:qvhHV OPT
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
# Realease
#
	r)
		VER="$OPTARG"
	;;
#
# Architecture
#
	a)
		ARCH="$OPTARG"
	;;
#
# Number of Disks
#
	n)
		NUMDISK="$OPTARG"
	;;
#
# Media
#
	m)
		MEDIA="$OPTARG"
	;;
#
# Protocol
#
	p)
		PROT="$OPTARG"
	;;
#
# Host
#
	s)
		HOST="$OPTARG"
	;;
#
# Path
#
	P)
		UPATH="$OPTARG"
	;;
#
# Type
#
	t)
		TYPE="$OPTARG"
	;;
#
# Check
#
	c)
		TESTGO="TRUE"
	;;
#
# Rel;ative destination directory
#
	d)
		DDIR="$OPTARG"
	;;
#
# Absolute destination directory
#
	D)
		ADIR="$OPTARG"
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
# Check Release
#
if [ -z "${VER}" ]
then
 _ADM__Log 3 "Need to specify a release version with -r " 1 $SENDEML 1
 _ADM__Log 1 "$USAGE" 1 $SENDEML 1
 EXITSTAT=11
 _ADM__exit $EXITSTAT
fi
#
# Architecture
#
_GetRepo_CheckList "$ARCH" "$ARCHES" "Need to specify an architecture, -a" 12
ARCH="${SETTEST}"
#
# Number of disks
#
MATCH=$(echo $NUMDISK | grep -E "^[^0-9]")
if [ -n "${MATCH}" ]
then
 NUMDISK=""
fi
if [ -z "${NUMDISK}" ]
then
 _ADM__Log 3 "Need to specify the number of disks to get of getting iso images. This must be an integer. 0 means let program decide" 1 $SENDEML 1
 _ADM__Log 1 "$USAGE" 1 $SENDEML 1
 EXITSTAT=13
 _ADM__exit $EXITSTAT
fi
#
# Media
#
_GetRepo_CheckList "$MEDIA" "$MEDIAS" "Need to specify a media, -a" 14
MEDIA="${SETTEST}"
#
# Protocol
#
_GetRepo_CheckList "$PROT" "$PROTS" "Need to specify a protocol, -p" 15
PROT="${SETTEST}"
case $PROT in
	http|ftp) COM="wget"
		  COMOPT="-r -l 1"
	;;
	rsync)	COM="rsync"
		COMOPT="-av"
	;;
	*)
		_ADM__Log 3 "Invalid protocol - $PROT" 1 $SENDEML 1
		_ADM__Log 1 "$USAGE" 1 $SENDEML 1
		EXITSTAT=19
		_ADM__exit $EXITSTAT
	;;
esac
#
# Host
#
if [ -z "${HOST}" ]
then
 _ADM__Log 3 "Need to specify a host to get the files" 1 $SENDEML 1
 _ADM__Log 1 "$USAGE" 1 $SENDEML 1
 EXITSTAT=16
 _ADM__exit $EXITSTAT
fi
#
# Path
#
if [ -z "${UPATH}" ]
then
 _ADM__Log 3 "Need to specify a path on the host (URL) to get the files" 1 $SENDEML 1
 _ADM__Log 1 "$USAGE" 1 $SENDEML 1
 EXITSTAT=17
 _ADM__exit $EXITSTAT
fi
#
# Type of files
#
_GetRepo_CheckList "$TYPE" "$TYPES" "Need to specify a type of data, -t" 18
TYPE="${SETTEST}"
#
# Absolute destination directory
#
if [ ! -d "$ADIR" ]
then
 _ADM__Log 3 "Absolution destination directory does not exist" 1 $SENDEML 1
 _ADM__Log 1 "$USAGE" 1 $SENDEML 1
 EXITSTAT=18
 _ADM__exit $EXITSTAT
fi
cd "${ADDIR}"
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
