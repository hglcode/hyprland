#!/bin/bash
set -euo pipefail

# 获取当前活动窗口信息
win=$(hyprctl activewindow -j)
addr=$(echo "$win" | jq -r '.address')
class=$(echo "$win" | jq -r '.class')

# 获取当前工作区 ID
cws=$(hyprctl activeworkspace -j | jq '.id')

# 如果没有活动窗口或 class 无效，则退出
[ -z "$class" ] || [ "$class" = "null" ] && exit 0


# 获取当前工作区内所有同类窗口的地址列表
mapfile -t addrs < <(hyprctl clients -j | jq -r \
    --arg class "$class" \
    --argjson ws "$cws" \
    '.[] | select(.class == $class and .workspace.id == $ws) | .address')

count=${#addrs[@]}

# 如果只有一个或零个同类窗口，提示并退出
if [ "$count" -le 1 ]; then
    hyprctl notify 0 1000 "rgb(ffff00)" "No other windows of this class in current workspace"
    exit 0
fi

# 查找当前窗口在列表中的索引
curr_idx=-1
for i in "${!addrs[@]}"; do
    if [ "${addrs[$i]}" = "$addr" ]; then
        curr_idx=$i
        break
    fi
done

if [ $curr_idx -eq -1 ]; then
    exit 0
fi

# 确定下一个索引，支持方向参数
direction="${1:-next}"
if [ "$direction" = "prev" ]; then
    next_idx=$(( (curr_idx - 1 + count) % count ))
else
    next_idx=$(( (curr_idx + 1) % count ))
fi

# 聚焦到目标窗口
hyprctl dispatch focuswindow address:${addrs[$next_idx]}

# 短暂等待确保焦点切换完成
hyprctl dispatch bringactivetotop
