#!/bin/bash

if [ "$USE_APT_MIRROR" = "true" ]; then
    echo "using apt mirror ..."
    cp -f $INST_SCRIPTS/apt_mirror/sources.list /etc/apt/sources.list
    rm -f /etc/apt/sources.list.d/ubuntu.sources
fi
