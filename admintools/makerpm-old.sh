#!/bin/bash
#
#
NAME=$(basename $PWD)
#
SPECFILE=${NAME}.spec
VERSION=$(cat $SPECFILE | grep "Version: " | cut -d ":" -f2 | sed -e s/" "//g)
RELEASE=$(cat $SPECFILE | grep "Release: " | cut -d ":" -f2 | sed -e s/" "//g)
RPMLOC="/usr/src/redhat/RPMS/i386"
RPMSLOCL="/usr/src/redhat/SOURCES"
RPMNAME=${NAME}-${VERSION}-${RELEASE}.i386.rpm
#
echo "tgzing files"
tar zcvf ${NAME}-${VERSION}.tgz ${NAME}-${VERSION}
#
echo "Copying gzip file to RPM sources"
cp ${NAME}-${VERSION}.tgz $RPMSLOCL
#
#vi $SPECFILE
rpmbuild -ba --target=i386 $SPECFILE
cp ${RPMLOC}/${RPMNAME} .
scp ${RPMLOC}/${RPMNAME} rbshare:///var/ftp/pub/Linux
scp ${RPMLOC}/${RPMNAME} ubcshare:///var/ftp/pub/Linux
#
