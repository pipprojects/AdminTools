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
# Rob Dancer	Add IMAP folder and comman name		1.4	18 June 2007
#
# Rob Dancer	V1.0	18/June 2007
# gen-cc-forward.sh
#
# Rob Dancer	1.0	16 January 2008
# gen-aliases.sh
#
# Rob Dancer	1.0	5 February 2008
# gen-dhcp.sh
#
# Rob Dancer	1.0	6 February 2008
# sed-text.sh
#
# Rob Dancer	1.1	23 October 2008
# Add -s, -e and -A options
#
VERSION="1.1, 23 October 2008"
#
#*****************************************************************************
#
#
# Main function
#
function _Main {
#
# Insert user function here
#
#
 DATESTAMP=$(date)
 if [ $TAGADD -eq 1 ]
 then
  echo "$TAGSTART" >> $TMPFILE1
  echo "$COMMENTCHAR" >> $TMPFILE1
  echo "$COMMENTCHAR $DATESTAMP" >> $TMPFILE1
  echo "$COMMENTCHAR" >> $TMPFILE1
  echo "$COMMENTCHAR ${PLUGTEXT}" >> $TMPFILE1
  echo "$COMMENTCHAR $PROGCALL" >> $TMPFILE1
  echo "$COMMENTCHAR" >> $TMPFILE1
  cat $TMPPLUGFILE >> $TMPFILE1
  echo "$COMMENTCHAR" >> $TMPFILE1
  echo "$TAGEND" > $TMPFILE3
 else
  cat $TMPPLUGFILE >> $TMPFILE1
 fi
#
 echo "#!/bin/sed" > $TMPFILE2
 echo "#" >> $TMPFILE2
 echo "${SEDLINE}" >> $TMPFILE2
 if [ $TAGADD -eq 1 ]
 then
  cat $TMPFILE1 | sed -e s/'\\'/'\\\\'/g -e s/"$"/'\\'/g | cat - $TMPFILE3 >> $TMPFILE2
 else
#
# Do not print "\" on last line so a blank lin eis not written out
#
  cat $TMPFILE1 | head -n -1 | sed -e s/'\\'/'\\\\'/g -e s/"$"/'\\'/g >> $TMPFILE2
  cat $TMPFILE1 | tail -n -1 >> $TMPFILE2
 fi
#
 cat $FILEIN | sed -f $TMPFILE2 > ${TMPFILE5}
 case $WRITEOUT in
	Y) cat $TMPFILE5
	;;
	*) cat $TMPFILE5 > $FILEOUT
	;;
 esac
 rm -f $TMPFILE1 $TMPFILE2 $TMPFILE3 $TMPPLUGFILE $TMPFILE5
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
FILEIN=""
FILEOUT=""
FILEOUT=""
PLUGFILE=""
TAGDEF=""
SEDCOM=""
PLUGTEXT="Plugged file"
COMMENTCHAR="#"
WRITEOUT="N"
let "TAGCHECK=0"
let "TAGADD=1"
TAGSTART=""
TAGEND=""
#
TMPFILE1="tmp-1.$$.tmp"
TMPFILE2="tmp-2.$$.tmp"
TMPFILE3="tmp-3.$$.tmp"
TMPPLUGFILE="tmp-4.$$.tmp"
TMPFILE5="tmp-5.$$.tmp"
#
#
VERBOSE=0
SENDSTD=1
#
PROGCALL="$0 $*"
#
# Initialise exit status
#
let "EXITSTAT=0"
#
# Get command line options
#
USAGE="$PROGNAME -p PlugFile -i InFile ([-t Tag] [-C CommentCharacter] [-m Message]) | (-s StartTag -e EndTag) [-o OutFile] -c acdi [-A] [-q] [-v] [-h] [-H] [-V]"
HELPINFO[1]="-p Plug file - file to be inserted between markers"
HELPINFO[2]="-i In file"
HELPINFO[3]="-t Tag"
HELPINFO[4]="-C Commant character [$COMMENTCHAR]"
HELPINFO[5]="-m Message"
HELPINFO[6]="-s Tag Start"
HELPINFO[7]="-e Tag End"
HELPINFO[8]="-A Do Not add additional information to plug, eg from -m Message"
HELPINFO[9]="-o Out file [standard out]"
HELPINFO[10]="-c sed command: a-append, c-change, d-delete, i-insert"
HELPINFO[11]="-v Verbose information"
HELPINFO[12]="-q Quiet output (none to stdio/stderr)"
HELPINFO[13]="-h This help"
HELPINFO[14]="-H Help and examples"
HELPINFO[15]="-V Version"
NUMHELP=15
#
while getopts p:i:t:C:s:e:o:c:m:AqvhHV OPT
do
 case $OPT in
#
# Invalid option
#
        \?)
                if [ -z "$OPTARG" ]
                then
		 _ADM__Log 0 "$VERSION" 1 $SENDEML 0 $VERBOSE 0
		 _ADM__Log 0 "$USAGE" 1 $SENDEML 0 $VERBOSE 0
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
# Plug file
#       
	p)      
		PLUGFILE="$OPTARG"
	;;
#
# In file
#       
	i)      
		FILEIN="$OPTARG"
	;;
#
# Tag
#       
	t)      
		TAGDEF="$OPTARG"
	;;
#
# Comment character
#       
	C)      
		COMMENTCHAR="$OPTARG"
	;;
#
# Message
#       
	m)      
		PLUGTEXT="$OPTARG"
	;;
#
# Tag Start
#
        s)
                TAGSTART="$OPTARG"
		let "TAGCHECK=1"
        ;;
#
# Tag End
#
        e)
                TAGEND="$OPTARG"
		let "TAGCHECK=1"
        ;;
#
# Out file
#       
	o)      
		FILEOUT="$OPTARG"
	;;
#
# sed command
#       
	c)      
		SEDCOM="$OPTARG"
	;;
#
# Add extra information
#       
	A)      
		let "TAGADD=0"
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
 _ADM__Log 1 "Starting $PROGNAME" 0 $SENDEML 1 $VERBOSE 0
fi
_ADM__Log 1 "$PROGNAME $*" 0 $SENDEML 1 $VERBOSE 0
#
# Check for show version
#
if [ "$SHOWVERSION" = "TRUE" ]
then
 SENDEML=0
 _ADM__Log 0 "$VERSION" 1 $SENDEML 0 $VERBOSE 0
 _ADM__Log 0 "$USAGE" 1 $SENDEML 0 $VERBOSE 0
 _ADM__exit $EXITSTAT
fi
#
# Check plug file
#
if [ -z "$PLUGFILE" ]
then
 _ADM__Log 3 "Plug file must be specified" 1 $SENDEML 1 $VERBOSE 0
 EXITSTAT="7"
 _ADM__exit $EXITSTAT
fi
 if [ ! -r "$PLUGFILE" -o ! -e "$PLUGFILE" ]
then
 EXITSTAT="5"
 _ADM__Log 3 "Plug file must be readable and exist" 1 $SENDEML 1 $VERBOSE 0
 _ADM__exit $EXITSTAT
fi
#
# Check in file
#
if [ -z "$FILEIN" ]
then
 FILEIN="-"
fi
if [ "$FILEIN" != "-" ]
then
 if [ ! -r "$FILEIN" -o ! -e "$FILEIN" ]
 then
  _ADM__Log 3 "Input must be readable and exist" 1 $SENDEML 1 $VERBOSE 0
  EXITSTAT="10"
  _ADM__exit $EXITSTAT
 fi
fi
#
# Check out file
#
if [ -z "$FILEOUT" -o "$FILEOUT" = "-" ]
then
 FILEOUT="$TMPFILE5"
 WRITEOUT="Y"
fi
if [ ! -w "$FILEOUT" -a -e "$FILEOUT" ]
then
 _ADM__Log 3 "Output must be writeable" 1 $SENDEML 1 $VERBOSE 0
 EXITSTAT="11"
 _ADM__exit $EXITSTAT
fi
#
# Check comment character
#
if [ -z "$COMMENTCHAR" ]
then
 _ADM__Log 3 "Comment character must not be null" 1 $SENDEML 1 $VERBOSE 0
 EXITSTAT="13"
 _ADM__exit $EXITSTAT
fi
#
# Check which mode so can set tag start and tag end
#
if [ $TAGCHECK -eq 0 ]
then
#
# Set tags
#
 TAGSTART="${COMMENTCHAR}${TAGDEF}++"
 TAGEND="${COMMENTCHAR}${TAGDEF}--"
#
fi
#
# Check sed command
#
# /^${TAGSTART}/a\
# /^${TAGSTART}/,/^${TAGEND}/c\
# /^${TAGSTART}/,/^${TAGEND}/d\
# /^${TAGSTART}/i\
#
case $SEDCOM in
	a)
	   SEDTEXT="appending"
	   SEDPARTS=""
	   SEDLEND="\\"
	   cat $PLUGFILE > $TMPPLUGFILE
	;;
	c)
	   SEDTEXT="changing"
	   SEDPARTS=",/^${TAGEND}/"
	   SEDLEND="\\"
	   cat $PLUGFILE > $TMPPLUGFILE
	;;
	d)
	   SEDTEXT="deleting"
	   SEDPARTS=",/^${TAGEND}/"
	   SEDLEND=""
#
# Delete is really change put not adding anything
#
	   SEDLEND="\\"
	   SEDCOM="c"
#
	   cat /dev/null > $TMPPLUGFILE
	;;
	i)
	   SEDTEXT="inserting"
	   SEDPARTS=""
	   SEDLEND="\\"
	   cat $PLUGFILE > $TMPPLUGFILE
	;;
	*)
	   if [ -z "$SEDCOM" ]
	   then
	    _ADM__Log 3 "sed command required" 1 $SENDEML 1 $VERBOSE 0
	    EXITSTAT="12"
	   else
	    _ADM__Log 3 "Invalid sed command: $SEDCOM" 1 $SENDEML 1 $VERBOSE 0
	    EXITSTAT="8"
	   fi
	   _ADM__Log 0 "$USAGE" 1 $SENDEML 1 $VERBOSE 0
	   _ADM__exit $EXITSTAT
	;;
esac
#
SEDLINE="/^${TAGSTART}/${SEDPARTS}${SEDCOM}${SEDLEND}"
#
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
