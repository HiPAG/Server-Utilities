#!/bin/bash

if [ ! -t 0 ];then
    read files
    filter="$1"
else
    files="`ls ${1:-something_that_does_not_exist}/${2-*} 2>/dev/null | shuf`"
    filter="$3"
fi

for file in $files
do
    [ -n "$filter" ] && ! "$filter" "$file" && continue
    echo $file && [ -f "$file" ] && code -w "$file"
done