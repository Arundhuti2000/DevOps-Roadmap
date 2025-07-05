#!/bin/bash

# Function: Total CPU Usage (over 1 second sample)
get_cpu_usage() {
    echo "🧠 CPU Usage:"
    cpu1=($(grep '^cpu ' /proc/stat))
    sleep 1
    cpu2=($(grep '^cpu ' /proc/stat))

    total1=0
    total2=0
    for val in "${cpu1[@]:1}"; do total1=$((total1 + val)); done
    for val in "${cpu2[@]:1}"; do total2=$((total2 + val)); done

    idle1=$((cpu1[4] + cpu1[5]))
    idle2=$((cpu2[4] + cpu2[5]))

    total_delta=$((total2 - total1))
    idle_delta=$((idle2 - idle1))

    cpu_usage=$(awk "BEGIN { printf \"%.1f\", (100 * ($total_delta - $idle_delta)) / $total_delta }")
    echo "   Total CPU Usage: $cpu_usage%"
}

# Function: Memory Usage
get_memory_usage() {
    echo "🧵 Memory Usage:"
    read -r _ total used free shared buff_cache available < <(free -m | awk '/^Mem:/ {print $1, $2, $3, $4, $5, $6, $7}')
    mem_used=$((total - free - buff_cache))
    percent=$(awk "BEGIN { printf \"%.1f\", ($used / $total) * 100 }")
    echo "   Used: ${used}MB | Free: ${free}MB | Total: ${total}MB | Usage: ${percent}%"
}

# Function: Disk Usage
get_disk_usage() {
    echo "💽 Disk Usage:"
    df -h --total --output=source,size,used,avail,pcent | tail -n 1 | awk '{printf "   Used: %s | Free: %s | Total: %s | Usage: %s\n", $3, $4, $2, $5}'
}

# Function: Top 5 CPU-Heavy Processes
top_cpu_processes() {
    echo "🔥 Top 5 Processes by CPU:"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6 | awk 'NR==1 {printf "   %-6s %-20s %-6s %-6s\n", $1, $2, $3, $4} NR>1 {printf "   %-6s %-20s %-6s %-6s\n", $1, $2, $3, $4}'
}

# Function: Top 5 Memory-Heavy Processes
top_mem_processes() {
    echo "🧠 Top 5 Processes by Memory:"
    ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6 | awk 'NR==1 {printf "   %-6s %-20s %-6s %-6s\n", $1, $2, $3, $4} NR>1 {printf "   %-6s %-20s %-6s %-6s\n", $1, $2, $3, $4}'
}

# Main dashboard
echo "==========================================="
echo "       📊 Server Performance Stats"
echo "==========================================="
get_cpu_usage
echo ""
get_memory_usage
echo ""
get_disk_usage
echo ""
top_cpu_processes
echo ""
top_mem_processes
echo ""
