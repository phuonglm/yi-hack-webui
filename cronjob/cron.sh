#!/bin/bash
IFS=' ' read -r -a HOSTS <<< "$CAMERAS"
LCD="${DATA_PATH:-/data}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cronjob started"

for HOST in ${HOSTS[@]}; do
    HOST_CUSTOM_SCRIPT_VAR=CUSTOM_SCRIPT_${HOST//./_};
    SCRIPT_URL=`echo "${!HOST_CUSTOM_SCRIPT_VAR}"`;
    if [ ! -z $SCRIPT_URL ]; then
        echo "down custom script for host $HOST from $SCRIPT_URL"
        curl -sS "$SCRIPT_URL" -o "/tmp/$HOST"
    fi
done


while [[ true ]]; do
    for HOST in ${HOSTS[@]}; do
        if [ -f "/tmp/$HOST" ]; then
            echo "use custom script for host $HOST"
            bash "/tmp/$HOST" $HOST
            continue;
        fi
    done
    sleep $DOWNLOAD_INVERVAL
done

