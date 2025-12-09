#!/bin/bash

if [ "$USE_APT_MIRROR" = "true" ]; then
    echo "using apt mirror ..."
    cp -f $INST_SCRIPTS/apt_mirror/sources.list /etc/apt/sources.list
    cp -f $INST_SCRIPTS/apt_mirror/sources.list.d/kisak-ubuntu-turtle-focal.list.mirror /etc/apt/sources.list.d/kisak-ubuntu-turtle-focal.list
else
    cp -f $INST_SCRIPTS/apt_mirror/sources.list.d/kisak-ubuntu-turtle-focal.list /etc/apt/sources.list.d/kisak-ubuntu-turtle-focal.list
fi
