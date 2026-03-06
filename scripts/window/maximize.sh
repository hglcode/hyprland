#!/bin/sh
# 增强版手动伪全屏：支持平铺 -> 浮动 -> 全屏的自动切换

set -eu

# 获取当前窗口地址和信息
win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')

if [ -z "$add" ] || [ "$add" = "null" ]; then
    hyprctl notify 0 1000 "rgb(ffff00)" "No active window"
    exit 1
fi

# 解析当前窗口是否为浮动 (floating: true/false)
floated=$(echo "$win" | jq -r '.floating')

cursor="/tmp/hypr/clients/$add/settiled/cursor"
normalize="/tmp/hypr/clients/$add/floating/normalize"
maximize="/tmp/hypr/clients/$add/floating/maximize"
[ -f "$maximize" ] && exit 0


if [ "$floated" != "true" ]; then
    mkdir -p "$(dirname "$cursor")"
    hyprctl cursorpos -j > "$cursor"
    self=$(readlink -f "$0")
    here=$(dirname "$self")
    "$here/../toggle_floating.sh" maximize
else
    mkdir -p "$(dirname "$normalize")"
    echo "$win" > "$normalize"
fi
mkdir -p "$(dirname "$maximize")"
touch "$maximize"

# 3. 强制移动到左上角并铺满屏幕
hyprctl dispatch resizeactive  exact 100% 100%
hyprctl dispatch moveactive exact 0 0
hyprctl dispatch bringactivetotop
