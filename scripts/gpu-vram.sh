#!/bin/bash
used=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
total=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)
used_gb=$(echo "scale=1; $used / 1024" | bc | sed 's/^\./0./')
total_gb=$(echo "scale=1; $total / 1024" | bc)

echo "${used_gb}G/${total_gb}G"
