#!/bin/bash
# 窗口最小化脚本

# 获取当前窗口地址和信息
win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')
if [ -z "$add" ] || [ "$add" == "null" ]; then
    echo "Error: No active window found"
    exit 1
fi

# 最小化窗口（移动到特殊工作区）
hyprctl dispatch movetoworkspace special:minimize
