#!/bin/bash
ps -e -o uid,%mem --no-headers | awk '{mem_count[$1]+=$2} END {for (i in mem_count) if (i!=0 && mem_count[i]>10) print i, mem_count[i]}' | sort -rnk 2