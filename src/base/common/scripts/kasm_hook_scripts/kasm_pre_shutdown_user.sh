#!/usr/bin/env bash

APP_NAME=$(basename "$0")

log () {
    if [ ! -z "${1}" ]; then
        LOG_LEVEL="${2:-DEBUG}"
        INGEST_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "${INGEST_DATE} ${LOG_LEVEL} (${APP_NAME}): $1"
    fi
}

cleanup() {
    log "The kasm_pre_shutdown_user script was interrupted." "ERROR"
}

trap cleanup 2 6 9 15

log "Executing kasm_pre_shutdown_user.sh" "INFO"

PAUSE_ON_EXIT="false"

for x in {1..10}
do

    if [[ $(timeout 1 wmctrl -l | awk '{$3=""; $2=""; $1=""; print $0}' | grep -i chrome) ]]
    then
        PAUSE_ON_EXIT="true"
        echo "Closing Chrome Windows Attempt ($x)..."
        timeout 1 wmctrl -c chrome
        sleep .5
    fi

done

for x in {1..10}
do

    if [[ $(timeout 1 wmctrl -l | awk '{$3=""; $2=""; $1=""; print $0}' | grep -i firefox) ]]
    then
        PAUSE_ON_EXIT="true"
        echo "Closing Firefox Windows Attempt ($x)..."
        timeout 1 wmctrl -c firefox
        sleep .5
    fi

done

if [ "${PAUSE_ON_EXIT}" == "true" ] ;
then
    echo "Sleeping..."
    sleep 1
fi

echo "Done"