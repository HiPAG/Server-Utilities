#!/bin/bash

THRESH=$1

while :; do
    CUDA_VISIBLE_DEVICES=$(nvidia-smi | sed -n -E 's/.* ([0-9]+)MiB \/ ([0-9]+)MiB .*/\1 \2/p' | awk '$2-$1>'"$THRESH"'{printf "%d %d\n",NR-1,$2-$1}' | sort -rnk2 | awk '{printf "%d,",$1}')
    export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES%,}
    test -n "$CUDA_VISIBLE_DEVICES" && { python -c "import os; print(os.environ['CUDA_VISIBLE_DEVICES'])"; break; }
    sleep 1
done