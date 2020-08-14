#!/bin/bash
cat /proc/loadavg | awk '{print $1}' | awk '{ printf("Current CPU Utilization is: %.2f%\n"), $0;}'
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 }' | awk '{ printf("Current Disk Usage is: %.2f%\n"), $0;}'
free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }' | awk '{ printf("Current Memory Utilization is: %.2f%\n"), $0;}'