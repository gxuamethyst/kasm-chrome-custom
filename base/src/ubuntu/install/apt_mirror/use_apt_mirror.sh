#!/bin/bash

if [ "$USE_APT_MIRROR" = "true" ]; then
    echo "using apt mirror ..."
    sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
    sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
    sed -i 's/http://ppa.launchpad.net/launchpad.proxy.ustclug.org/g' /etc/apt/sources.list /etc/apt/sources.list.d/*.list
    sed -ri 's#(.*http)(://launchpad.proxy.ustclug.org.*)#\1s\2#g' /etc/apt/sources.list /etc/apt/sources.list.d/*.list
fi
