#!/bin/bash
LCD="${DATA_PATH:-/data}"
if [ -z "$1" ]; then
    echo "no host input, please use yi-hack-v5.sh <hostname/ip>"
    exit
else
    HOST=$1
    ping -c 5 $HOST > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        echo "Cannot ping $HOST please check your network connection"
        exit;
    fi

    nc -z -w 5 $HOST 23
    if [ $? -eq 1 ]; then
        echo "Telnet service on $HOST seem down, please check your camera again."
        exit;
    fi

    nc -z -w 5 $HOST 21
    if [ $? -eq 1 ]; then
        echo "FTP service on $HOST seem down, please check your camera again."
        exit;
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
    DELETE_RECORD_DIRs=`lftp -c "open '$HOST' -u $TELNET_USER:$TELNET_PASSWORD; ls /tmp/sd/record" | grep -v "last_motion_check" | awk '{printf "%s", $9" "}' | awk '{$NF="";sub(/[ \t]+$/,"")}1'`
    lftp -c "set ftp:use-mdtm no;
    open '$HOST' -u $TELNET_USER:$TELNET_PASSWORD;
    lcd $LCD/$HOST;
    cd /tmp/sd/record;
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
        exit;
    fi

    nc -z -w 5 $HOST 23
    if [ $? -eq 1 ]; then
        echo "Telnet service on $HOST seem down, please check your camera again."
        exit;
    fi

    if [[ $DELETE_RECORD_DIRs = *[!\ ]* ]]; then
        (sleep 1
        echo ${TELNET_USER}
        sleep 1
        echo ${TELNET_PASSWORD}
        sleep 1
        echo "cd /tmp/sd/record && rm -rf $DELETE_RECORD_DIRs"
        sleep 4
        ) | telnet $HOST > /dev/null 2>&1
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] done"
fi