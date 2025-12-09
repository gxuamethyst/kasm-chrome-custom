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
    log "The kasm_end_session_recoverable script was interrupted." "ERROR"
}

trap cleanup 2 6 9 15

log "Executing kasm_end_session_recoverable.sh" "INFO"

echo "Done"