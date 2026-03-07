#!/bin/sh

set -u

[ $# -lt 1 ] && exit 1

if [ "$1" = "off" ]; then
    mkdir -p /tmp/monitor
    ddcutil getvcp 10 | cut -d'=' -f2 | cut -d',' -f1 | tr -d ' ' | tee /tmp/monitor/backlight
    ddcutil setvcp 10 1
else
    ddcutil setvcp 10 "$(cat /tmp/monitor/backlight 2>/dev/null || echo 66)"
fi
