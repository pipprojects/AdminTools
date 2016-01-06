#!/bin/bash
#
HERE="$PWD"
SDIR=$(basename "$HERE")
#
. ./makerpm.src
#
su - $RPMUSER -c "${HERE}/makerpm.sh ${HERE}"
#
