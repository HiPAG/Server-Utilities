#!/bin/bash
kill $(ps aux | grep -v PID | sort -rnk3,4 | head -n 10 | awk '$3>900 && $2>1000 {print $2}')
