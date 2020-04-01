#!/bin/bash

THRESH=5000 

CUDA_VISIBLE_DEVICES=$(nvidia-smi | sed -n -E 's/.* ([0-9]+)MiB \/ ([0-9]+)MiB .*/\1 \2/p' | awk '$2-$1>'"$THRESH"'{printf "%d,",NR-1}')
export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES%,}

python -c "import os; print(os.environ['CUDA_VISIBLE_DEVICES'])"