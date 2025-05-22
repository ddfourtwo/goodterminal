#!/bin/bash
# Accurate memory usage script for tmux status bar that matches Activity Monitor

# Get page size
pagesize=$(vm_stat | head -1 | grep -o '[0-9]*')

# Extract page counts (get first match only)
free=$(vm_stat | grep '^Pages free:' | awk '{print $3}' | tr -d '.')
active=$(vm_stat | grep '^Pages active:' | awk '{print $3}' | tr -d '.')
inactive=$(vm_stat | grep '^Pages inactive:' | awk '{print $3}' | tr -d '.')
wired=$(vm_stat | grep '^Pages wired down:' | awk '{print $4}' | tr -d '.')

# Calculate memory in GB with one decimal place (Activity Monitor shows active + inactive + wired as "used")
total_bytes=$(sysctl -n hw.memsize)
total_gb=$(echo "scale=1; $total_bytes / 1024 / 1024 / 1024" | bc)
used_pages=$((active + inactive + wired))
used_bytes=$((used_pages * pagesize))
used_gb=$(echo "scale=1; $used_bytes / 1024 / 1024 / 1024" | bc)

echo "${used_gb}/${total_gb}GB"