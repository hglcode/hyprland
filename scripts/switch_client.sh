#!/bin/sh
set -u

mode="${1:-workspace}"
direction="${2:-next}"

# ====================== 1. 获取基础信息 ======================
# 获取当前活动窗口信息（JSON格式）
win=$(hyprctl activewindow -j)
# 提取当前窗口地址（唯一标识）
addr=$(echo "$win" | jq -r '.address')
# 提取当前窗口class
class=$(echo "$win" | jq -r '.class')
# 获取浮动状态
float=$(echo "$win" | jq -r '.floating')
# 提取当前工作区ID
cwid=$(hyprctl activeworkspace -j | jq '.id')

# 校验：如果没有活动窗口/地址无效，直接退出
[ -z "$addr" ] || [ "$addr" = "null" ] && exit 0

# ====================== 2. 获取窗口列表 ======================
if [ "$mode" = "group" ]; then
    addrs=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$class\" and .workspace.id == $cwid) | .address")
elif [ "$mode" = "workspace" ]; then
    addrs=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $cwid) | .address")
else
    echo "Invalid mode: $mode. Use 'group' or 'workspace'."
    exit 1
fi

count=$(echo "$addrs" | wc -l)
printf "%s\n" "$addrs"
echo "$count"
if [ "$count" -le 1 ]; then
    hyprctl notify 0 1000 "rgb(ffff00)" "No other windows of this class in current workspace"
    exit 0
fi

# ====================== 3. 查找当前窗口在列表中的位置 ======================
curr_idx=$(echo "$addrs" | awk -v addr="$addr" '$0 == addr {print NR-1; exit}')

echo "curr_idx: $curr_idx"

# 异常：如果当前窗口不在列表中，退出
if [ "$curr_idx" -eq -1 ]; then
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

# ====================== 5. 切换窗口并保持状态 ======================
# 检查当前窗口的浮动状态文件
float_file="/tmp/hypr/clients/$addr/floating/active"
if [ ! -f "$float_file" ] && [ "$float" = "false" ]; then
    hyprctl dispatch settiled
fi

# 聚焦到目标窗口
next_addr=$(echo "$addrs" | sed -n "$((next_idx + 1))p")
printf "next address: %s\n" "$next_addr"
hyprctl dispatch focuswindow "address:$next_addr"

# 保持浮动状态
if [ "$float" = "true" ]; then
    hyprctl dispatch setfloating
fi

# 确保窗口显示在最顶层，不受浮动窗口遮挡
hyprctl dispatch bringactivetotop

# 通知用户切换信息
hyprctl notify 0 1000 "rgb(00ff00)" "Switched to $next_addr"
