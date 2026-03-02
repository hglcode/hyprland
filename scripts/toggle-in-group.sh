#!/bin/bash
# 同类应用内窗口切换器（当前工作区限定），保持全屏状态
# 依赖: hyprctl, jq

set -euo pipefail

# 获取当前活动窗口信息
active_win=$(hyprctl activewindow -j)
active_addr=$(echo "$active_win" | jq -r '.address')
active_class=$(echo "$active_win" | jq -r '.class')
active_fullscreen=$(echo "$active_win" | jq -r '.fullscreen')

# 获取当前工作区 ID
current_ws=$(hyprctl activeworkspace -j | jq '.id')

# 如果没有活动窗口或 class 无效，则退出
if [ -z "$active_class" ] || [ "$active_class" = "null" ]; then
    exit 0
fi

# 获取当前工作区内所有同类窗口的地址列表
mapfile -t win_addrs < <(hyprctl clients -j | jq -r \
    --arg class "$active_class" \
    --argjson ws "$current_ws" \
    '.[] | select(.class == $class and .workspace.id == $ws) | .address')

count=${#win_addrs[@]}

# 如果只有一个或零个同类窗口，提示并退出
if [ $count -le 1 ]; then
    hyprctl notify -1 2000 "rgb(ff1ea3)" "No other windows of this class in current workspace"
    exit 0
fi

# 查找当前窗口在列表中的索引
current_index=-1
for i in "${!win_addrs[@]}"; do
    if [ "${win_addrs[$i]}" = "$active_addr" ]; then
        current_index=$i
        break
    fi
done

if [ $current_index -eq -1 ]; then
    exit 0
fi

# 确定下一个索引，支持方向参数
direction="${1:-next}"
if [ "$direction" = "prev" ]; then
    next_index=$(( (current_index - 1 + count) % count ))
else
    next_index=$(( (current_index + 1) % count ))
fi

# 聚焦到目标窗口
hyprctl dispatch focuswindow address:${win_addrs[$next_index]}

# 短暂等待确保焦点切换完成
sleep 0.01

# 将新窗口的全屏状态设置为与原来相同
if [ -n "$active_fullscreen" ] && [ "$active_fullscreen" != "null" ]; then
    hyprctl dispatch fullscreenstate "$active_fullscreen"
fi
