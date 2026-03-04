#!/bin/bash
# 增强版手动伪全屏：支持平铺 -> 浮动 -> 全屏的自动切换

set -euo pipefail

self=$(readlink -f "$0")
here=$(dirname "$self")

win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')

if [ -f "/tmp/hypr/clients/$add" ]; then
    bash "$here/window/normalize.sh"
else
    bash "$here/window/maximize.sh"
fi
