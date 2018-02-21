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
        #DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

        if [ ! -d "$LCD/$HOST" ]; then
          mkdir "$LCD/$HOST"
        fi

        DATE=`date +%YY%mM%dD`
        lftp -c "open '$HOST';
        lcd $LCD/$HOST;
        cd /tmp/hd1/record;
        mirror  \
               --Remove-source-files \
               --exclude-glob *.tmp \
               --verbose;
        " > /dev/null 2>&1

        DELETE_DIRs=`lftp -c "open '$HOST'; ls /tmp/hd1/record_sub" | grep -v "$DATE.*" | awk '{printf "%s", $9" "}'`
        if [[ $DELETE_DIRs = *[!\ ]* ]]; then
            ( echo open ${HOST}
            sleep 1
            echo ${TELNET_USER}
            sleep 1
            echo ${TELNET_PASSWORD}
            sleep 1
            echo "cd /tmp/hd1/record_sub && rm -rf $DELETE_DIRs"
            sleep 2
             ) | telnet > /dev/null 2>&1
        fi

        DELETE_DIRs=`lftp -c "open '$HOST'; ls /tmp/hd1/record" | grep -v "$DATE.*" | awk '{printf "%s", $9" "}'`
        if [[ $DELETE_DIRs = *[!\ ]* ]]; then
            ( echo open ${HOST}
            sleep 1
            echo ${TELNET_USER}
            sleep 1
            echo ${TELNET_PASSWORD}
            sleep 1
            echo "cd /tmp/hd1/record && rm -rf $DELETE_DIRs"
            sleep 2
             ) | telnet > /dev/null 2>&1
        fi
        echo "done"
    done
    sleep $DOWNLOAD_INVERVAL
done

