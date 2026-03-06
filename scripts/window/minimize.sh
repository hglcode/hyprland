#!/bin/sh
# 窗口最小化脚本
set -eu

# 获取当前窗口地址和信息
win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')

# 检查窗口地址是否有效
if [ -z "$add" ] || [ "$add" = "null" ]; then
    hyprctl notify 0 1000 "rgb(ffff00)" "No active window found"
    exit 1
fi

# 最小化窗口（移动到特殊工作区）
hyprctl dispatch movetoworkspace special:minimize

# 通知用户窗口已最小化
hyprctl notify 0 1000 "rgb(00ff00)" "Window minimized"
