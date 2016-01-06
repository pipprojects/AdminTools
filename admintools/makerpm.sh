#!/bin/bash
#
#
HERE="$1"
cd "${HERE}"
SDIR=$(basename "$HERE")
#
. ./makerpm.src
#
echo "tgzing files     ${NAME}-${VERSION}"
tar zcvf ${NAME}-${VERSION}.tgz ${NAME}-${VERSION}
#
echo "Copying gzip file to RPM sources $RPMSLOCL"
ls -al $RPMSLOCL
cp ${NAME}-${VERSION}.tgz $RPMSLOCL
#
#vi $SPECFILE
rpmbuild -ba --target=${TARGET} $SPECFILE
cp ${RPMLOC}/${RPMNAME} .
#
