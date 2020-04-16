#!/bin/bash

function send_instant_message()
{
    set -u
    
    local uid=$1
    local mesg="$2"
    local pts=`ls -ln /dev/pts/ | awk -v uid=$uid '$3==uid{print $10}'`

    for pts_ in $pts
    do
        echo -e "$mesg" >> /dev/pts/$pts_
    done
}

send_instant_message $1 "$2"