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

        ping -c 5 $HOST > /dev/null 2>&1
        if [ $? -eq 1 ]; then
            echo "Cannot ping $HOST please check your network connection"
            continue;
        fi

        nc -z -w 5 $HOST 23
        if [ $? -eq 1 ]; then
            echo "Telnet service on $HOST seem down, please check your camera again."
            continue;
        fi

        nc -z -w 5 $HOST 21
        if [ $? -eq 1 ]; then
            echo "FTP service on $HOST seem down, please check your camera again."
            continue;
        fi


        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Syncing time and date on camera $HOST";
        (sleep 1
        echo ${TELNET_USER}
        sleep 1
        echo ${TELNET_PASSWORD}
        sleep 4
        echo "mount | grep -q 'vfat (ro'; if [ \$? -eq 0 ]; then reboot; fi;"
        sleep 4
        echo "ntpd -q -n -p ${NTP_SERVER}"
        sleep 10
        ) | telnet $HOST > /dev/null 2>&1

        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Downloading all records from $HOST.";

        if [ ! -d "$LCD/$HOST" ]; then
          mkdir "$LCD/$HOST"
        fi

        # List record directory to delete, exclude 1 last item on record (current record directory)
        DELETE_RECORD_DIRs=`lftp -c "open '$HOST'; ls /tmp/hd1/record" | grep -v "last_motion_check" | awk '{printf "%s", $9" "}' | awk '{$NF="";sub(/[ \t]+$/,"")}1'`
        # List record directory to delete, exclude 1 last item on record_sub (current record directory)
        DELETE_RECORD_SUB_DIRs=`lftp -c "open '$HOST'; ls /tmp/hd1/record_sub" | awk '{printf "%s", $9" "}' | awk '{$NF="";sub(/[ \t]+$/,"")}1'`
        lftp -c "set ftp:use-mdtm no;
        open '$HOST';
        lcd $LCD/$HOST;
        cd /tmp/hd1/record;
        mirror  \
               --Remove-source-files \
               --exclude-glob *.tmp \
               --exclude-glob last_motion_check \
               --verbose;
        "
        #> /dev/null 2>&1

        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleaning up $HOST.";

        nc -z -w 5 $HOST 23
        if [ $? -eq 1 ]; then
            echo "Telnet service on $HOST seem down, please check your camera again."
            continue;
        fi

        if [[ $DELETE_RECORD_SUB_DIRs = *[!\ ]* ]]; then
            (sleep 1
            echo ${TELNET_USER}
            sleep 1
            echo ${TELNET_PASSWORD}
            sleep 1
            echo "cd /tmp/hd1/record_sub && rm -rf $DELETE_RECORD_SUB_DIRs"
            sleep 4
            ) | telnet $HOST > /dev/null 2>&1
        fi

        nc -z -w 5 $HOST 23
        if [ $? -eq 1 ]; then
            echo "Telnet service on $HOST seem down, please check your camera again."
            continue;
        fi

        if [[ $DELETE_RECORD_DIRs = *[!\ ]* ]]; then
            (sleep 1
            echo ${TELNET_USER}
            sleep 1
            echo ${TELNET_PASSWORD}
            sleep 1
            echo "cd /tmp/hd1/record && rm -rf $DELETE_RECORD_DIRs"
            sleep 4
            ) | telnet $HOST > /dev/null 2>&1
        fi
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] done"

    done
    sleep $DOWNLOAD_INVERVAL
done

