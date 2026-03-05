#!/bin/bash
set -euo pipefail

# 获取当前窗口地址和信息
win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')

# 检查窗口地址是否有效
if [ -z "$add" ] || [ "$add" == "null" ]; then
    hyprctl notify 0 1000 "rgb(ffff00)" "No active window"
    exit 1
fi

normalize="/tmp/hypr/clients/$add/floating/normalize"

# 检查normalize文件是否存在
if [ ! -f "$normalize" ]; then
    hyprctl notify 0 1000 "rgb(ffff00)" "No normalize information found"
    exit 1
fi

# 恢复窗口大小和位置
jq -r '.size | join(" ")' "$normalize" | xargs -r hyprctl dispatch resizeactive exact
jq -r '.at | join(" ")' "$normalize" | xargs -r hyprctl dispatch moveactive exact
hyprctl dispatch bringactivetotop

# 通知用户恢复成功
hyprctl notify 0 1000 "rgb(00ff00)" "Window restored to original size and position"
