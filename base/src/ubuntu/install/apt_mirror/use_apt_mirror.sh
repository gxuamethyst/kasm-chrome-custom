#!/bin/bash

if [ "$USE_APT_MIRROR" = "true" ]; then
    echo "using apt mirror ..."
    cp -f $INST_SCRIPTS/apt_mirror/source.list /etc/apt/source.list
    cp -f $INST_SCRIPTS/apt_mirror/source.list.d/kisak-ubuntu-turtle-focal.list.mirror /etc/apt/source.list.d/kisak-ubuntu-turtle-focal.list
else
    cp -f $INST_SCRIPTS/apt_mirror/source.list.d/kisak-ubuntu-turtle-focal.list /etc/apt/source.list.d/kisak-ubuntu-turtle-focal.list
fi
