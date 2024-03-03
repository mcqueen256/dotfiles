#!/bin/bash
day=$(date +%d)
suffix="th"
case "$day" in
01 | 21 | 31) suffix="st" ;;
02 | 22) suffix="nd" ;;
03 | 23) suffix="rd" ;;
esac
echo "$suffix"
