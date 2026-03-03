#!/bin/bash
set -euo pipefail

# 获取当前活动窗口信息
active_win=$(hyprctl activewindow -j)
#active_addr=$(echo "$active_win" | jq -r '.address')
#active_class=$(echo "$active_win" | jq -r '.class')
active_fullscreen=$(echo "$active_win" | jq -r '.fullscreen')

# 聚焦到目标窗口
hyprctl --batch "dispatch cyclenext; dispatch fullscreenstate $active_fullscreen"
