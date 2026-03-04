#!/bin/bash
set -euo pipefail

# 获取当前窗口地址和信息
win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')

if [ -z "$add" ] || [ "$add" == "null" ]; then
    hyprctl notify 0 1000 "rgb(ffff00)" "No active window"
    exit 1
fi

# 状态文件
state="/tmp/hypr/clients/$add"

[ -f "$state" ] || exit 1
# ------------------------------
# 退出伪全屏模式
# ------------------------------
# shellcheck disable=SC1090
source "$state"
rm -f "$state"
# shellcheck disable=SC2153
if [ "$FLOATED" != "true" ]; then
    hyprctl dispatch movecursor "$MOUSE_X" "$MOUSE_Y"
    hyprctl dispatch settiled
    exit 0
fi

hyprctl dispatch resizeactive exact "$WINDOW_W" "$WINDOW_H"
hyprctl dispatch moveactive exact "$WINDOW_X" "$WINDOW_Y"
