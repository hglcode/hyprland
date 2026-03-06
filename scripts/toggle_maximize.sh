#!/bin/sh
# 增强版手动伪全屏：支持平铺 -> 浮动 -> 全屏的自动切换

set -eu

self=$(readlink -f "$0")
here=$(dirname "$self")

win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')

maximize="/tmp/hypr/clients/$add/floating/maximize"
if [ -f "$maximize" ]; then
    if [ -f "/tmp/hypr/clients/$add/floating/active" ]; then
        "$here/window/normalize.sh"
    else
        "$here/toggle_floating.sh"
    fi
    /bin/rm -rf "/tmp/hypr/clients/$add/floating/maximize" > /dev/null 2> /dev/null || true
else
    echo xxxxxxxxxxxxxxxx
    [ ! -f "/tmp/hypr/clients/$add/floating/active" ] && "$here/toggle_floating.sh" maximize
    "$here/window/maximize.sh"
fi
hyprctl dispatch focuswindow "address:$add"
