#!/bin/bash

wget "$1" -O ".temp" -q 
suffix="$(cat .temp | grep -Po '/iel[0-9]/.*?\.pdf' | head -n1)"
filename=${2:-${suffix##*/}}
wget https://ieeexplore.ieee.org/ielx${suffix:4:1}/${suffix:6} -O "$filename"
rm .temp

# code "$filename"
