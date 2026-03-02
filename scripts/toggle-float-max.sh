#!/bin/bash

win_info=$(hyprctl activewindow -j)
[ -z "$win_info" ] || [ "$win_info" = "null" ] && exit 1

floating=$(echo "$win_info" | jq -r '.floating')
hyprctl dispatch togglefloating

# 如果原来是浮动的 (现在切回平铺了)，直接退出
[ "$floating" = "true" ] && exit 0

# 原来是平铺的，等待变为浮动状态，成功后立即移动
count=0
while [ $count -lt 30 ]; do
    # 修复：确保所有输出都通过 jq 处理
    json=$(hyprctl activewindow -j 2>/dev/null)
    floated=$(echo "${json:-{\}}" | jq -r '.floating // empty')

    if [ "$floated" = "true" ]; then
        hyprctl --batch "dispatch resizeactive exact 100% 100%"
        break
    fi
    sleep 0.05
    count=$((count+1))
done
