#!/bin/bash
function camera_data_download {
    if [ "$FTP_SERVER" != "true" ]; then
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
    fi
}
LCD="${DATA_PATH:-/data}"
if [ -z "$1" ]; then
    echo "no host input, please use yi-hack-v1.sh <hostname/ip>"
    exit
else
    HOST=$1
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

    if [ "$FTP_SERVER" != "true" ]; then
        if [ -f "/tmp/camera_download_$HOST.pid" ]; then
            PROC_PID=`cat /tmp/camera_download_$HOST.pid`
            kill -s 0 $PROC_PID
            if [ $? -eq 0 ]; then
                continue
            fi
        fi

        nc -z -w 5 $HOST 21
        if [ $? -eq 1 ]; then
            echo "FTP service on $HOST seem down, please check your camera again."
            continue;
        fi

        camera_data_download &
        echo "$!" > "/tmp/camera_download_$HOST.pid"
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] done"
fi