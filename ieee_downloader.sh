#!/bin/bash

wget "$1" -O ".temp" > /dev/null
suffix=$(cat .temp | grep -Po '/iel7/\K.*?\.pdf' | head -n1)
wget https://ieeexplore.ieee.org/ielx7/$suffix -O ${2:-${suffix##*/}}
rm .temp