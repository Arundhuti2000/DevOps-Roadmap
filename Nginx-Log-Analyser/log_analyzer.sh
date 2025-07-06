#!/bin/bash
echo "Top 5 IP requests:"
grep -oE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' access.log | sort | uniq -c | sort -nr | head -n 5 | awk '{print $2 " - " $1 " requests"}'
echo "**********************************"
echo "Top 5 most requested paths:"
awk -F'"' '{print $2}' access.log | awk '{print $2}' | sort | uniq -c | sort -nr | head -n 5 | awk '{print $2 " - " $1 " requests"}'
echo "**********************************"
echo "Top 5 response status codes:"
awk '{print $9}' access.log | sort | uniq  -c | sort -nr | head -n 5 | awk '{print $2 " - " $1 " requests"}'
echo "**********************************"
echo "Top 5 user agents:"
awk -F'"' '{print $6}' access.log | sed 's/^ //;s/"$//' | sort | uniq -c  | sort -nr | head -n 5 | awk '{print $2 " - " $1 " reuests"}'