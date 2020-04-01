#!/bin/bash

while :; do
    pids=$(ps -e -o ppid,uid --no-headers | awk '$2!=0 {proc_count[$1]+=1} END {for (i in proc_count) if(proc_count[i] > 1 && int(i) > 100) print i, proc_count[i]}' | awk '$2>9 {print $1}')
    if [ -n "$pids" ]; then
        for pid in $pids; do
            uid=`ps -p $pid -o uid=`
            echo $uid $pid `date +"%Y-%m-%d_%H:%M:%S"`
            /bin/kill -- -$pid $pid
            /home/linmanhui/Tools/send_mesg.sh $uid "\033[31m警告：由于占用过多进程资源，您的程序可能已被强制终止，请注意遵守规则！\033[0m"
        done
    fi
    sleep 30
done
