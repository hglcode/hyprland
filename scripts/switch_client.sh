#!/bin/bash
set -euo pipefail

mode="${1:-workspace}"
direction="${2:-next}"

# ====================== 1. 获取基础信息 ======================
# 获取当前活动窗口信息（JSON格式）
win=$(hyprctl activewindow -j)
# 提取当前窗口地址（唯一标识）
addr=$(echo "$win" | jq -r '.address')
# 提取当前窗口class
class=$(echo "$win" | jq -r '.class')
# 提取当前工作区ID
cws=$(hyprctl activeworkspace -j | jq '.id')

# 校验：如果没有活动窗口/地址无效，直接退出
[ -z "$addr" ] || [ "$addr" = "null" ] && exit 0

# ====================== 2. 获取窗口列表 ======================
if [ "$mode" = "group" ]; then
    # 筛选当前工作区内与当前窗口同类的所有窗口
    mapfile -t addrs < <(hyprctl clients -j | jq -r \
        --arg class "$class" \
        --argjson ws "$cws" \
        '.[] | select(.class == $class and .workspace.id == $ws) | .address')

    # 统计窗口数量
    count=${#addrs[@]}

    # 边界校验
    if [ $count -le 1 ]; then
        hyprctl notify 0 1000 "rgb(ffff00)" "No other windows of this class in current workspace"
        exit 0
    fi
elif [ "$mode" = "workspace" ]; then
    # 筛选当前工作区内的所有窗口地址（不限制class）
    mapfile -t addrs < <(hyprctl clients -j | jq -r \
        --argjson ws "$cws" \
        '.[] | select(.workspace.id == $ws) | .address')

    # 统计窗口数量
    count=${#addrs[@]}

    # 边界校验
    if [ $count -le 1 ]; then
        hyprctl notify 0 1000 "rgb(ffff00)" "No other windows in current workspace"
        exit 0
    fi
else
    echo "Invalid mode: $mode. Use 'group' or 'workspace'."
    exit 1
fi

# ====================== 3. 查找当前窗口在列表中的位置 ======================
curr_idx=-1
for i in "${!addrs[@]}"; do
    if [ "${addrs[$i]}" = "$addr" ]; then
        curr_idx=$i
        break
    fi
done

# 异常：如果当前窗口不在列表中，退出
if [ $curr_idx -eq -1 ]; then
    exit 0
fi

# ====================== 4. 计算下一个窗口索引（支持方向） ======================
if [ "$direction" = "prev" ]; then
    # 上一个：索引-1，加count避免负数，再取模
    next_idx=$(( (curr_idx - 1 + count) % count ))
else
    # 下一个：索引+1，取模实现循环
    next_idx=$(( (curr_idx + 1) % count ))
fi

# ====================== 5. 切换窗口并保持全屏状态 ======================
# 聚焦到目标窗口
hyprctl dispatch focuswindow "address:${addrs[$next_idx]}"

# 确保窗口显示在最顶层，不受浮动窗口遮挡
hyprctl dispatch bringactivetotop
