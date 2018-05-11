#!/bin/bash
IFS=' ' read -r -a HOSTS <<< "$CAMERAS"
LCD="/data"
echo "Cronjob started"
while [[ true ]]; do
    for HOST in ${HOSTS[@]}; do
        echo "Syncing $HOST"
        ( echo open ${HOST}
        sleep 1
        echo ${TELNET_USER}
        sleep 1
        echo ${TELNET_PASSWORD}
        sleep 1
        echo "ntpd -q -n -p ${NTP_SERVER}"
        sleep 10
         ) | telnet > /dev/null 2>&1

        if [ ! -d "$LCD/$HOST" ]; then
          mkdir "$LCD/$HOST"
        fi
        DELETE_RECORD_DIRs=`lftp -c "open '$HOST'; ls /tmp/hd1/record" | awk '{printf "%s", $9" "}' | awk '{$NF="";sub(/[ \t]+$/,"")}1'`
        DELETE_RECORD_SUB_DIRs=`lftp -c "open '$HOST'; ls /tmp/hd1/record_sub" | awk '{printf "%s", $9" "}' | awk '{$NF="";sub(/[ \t]+$/,"")}1'`
        lftp -c "open '$HOST';
        lcd $LCD/$HOST;
        cd /tmp/hd1/record;
        mirror  \
               --Remove-source-files \
               --exclude-glob *.tmp \
               --verbose;
        " > /dev/null 2>&1

        if [[ $DELETE_RECORD_SUB_DIRs = *[!\ ]* ]]; then
            ( echo open ${HOST}
            sleep 1
            echo ${TELNET_USER}
            sleep 1
            echo ${TELNET_PASSWORD}
            sleep 1
            echo "cd /tmp/hd1/record_sub && rm -rf $DELETE_RECORD_SUB_DIRs"
            sleep 2
             ) | telnet > /dev/null 2>&1
        fi

        if [[ $DELETE_RECORD_DIRs = *[!\ ]* ]]; then
            ( echo open ${HOST}
            sleep 1
            echo ${TELNET_USER}
            sleep 1
            echo ${TELNET_PASSWORD}
            sleep 1
            echo "cd /tmp/hd1/record && rm -rf $DELETE_RECORD_DIRs"
            sleep 2
             ) | telnet > /dev/null 2>&1
        fi
        echo "done"
    done
    sleep $DOWNLOAD_INVERVAL
done

