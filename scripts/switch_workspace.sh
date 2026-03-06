#!/bin/sh
set -eu

direction="${1:-next}"

# 获取当前工作区信息
current_workspace=$(hyprctl activeworkspace -j | jq '.id')

# 计算下一个工作区ID
if [ "$direction" = "prev" ]; then
    # 上一个工作区：ID-1，最小为1
    next_workspace=$((current_workspace - 1))
    if [ $next_workspace -lt 1 ]; then
        # 如果当前是第一个工作区，切换到最后一个工作区
        last_workspace=$(hyprctl workspaces -j | jq 'length')
        next_workspace=$last_workspace
    fi
else
    # 下一个工作区：ID+1
    next_workspace=$((current_workspace + 1))
fi

# 切换到目标工作区
hyprctl dispatch workspace "$next_workspace"
