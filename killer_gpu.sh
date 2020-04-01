#!/bin/bash

# Set username-UID mapping
root=0

# Set username-GPU mapping
dev0=(root)
dev1=(root)
dev2=(root)
dev3=(root)

while :;
do
    # Check validity
    for ((i=0;i<4;i++));
    do
        pids=(`nvidia-smi -i $i| awk 'NR>15 {print $3}' | head -n -1`)
        for pid in ${pids[@]};
        do
            if [[ ! "$pid" =~ [1-9][0-9]+ ]]; then
                continue
            fi
            cur_uid=`ps -p $pid -o uid= | sed 's/^[[:blank:]]*//'`
            cur_dev=dev$i
            white_list=$cur_dev[@]
            flag=1
            for username in ${!white_list};
            do
                uid=$username
                if [ ${!uid} = "$cur_uid" ]; then
                    flag=0
                    break
                fi
            done
            [ $flag -eq 1 ] && kill $pid
        done
    done

    sleep 30
done