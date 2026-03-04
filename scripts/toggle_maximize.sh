#!/bin/bash
# 增强版手动伪全屏：支持平铺 -> 浮动 -> 全屏的自动切换

set -euo pipefail

# 获取当前窗口地址和信息
win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')

if [ -z "$add" ] || [ "$add" == "null" ]; then
    hyprctl notify 0 1000 "rgb(ffff00)" "No active window"
    exit 1
fi

# 解析当前窗口是否为浮动 (floating: true/false)
floated=$(echo "$win" | jq -r '.floating')

# 状态文件
state="/tmp/hypr/clients/$add"
mkdir -p "$(dirname "$state")"

if [ -f "$state" ]; then
    # ------------------------------
    # 退出伪全屏模式
    # ------------------------------
    # shellcheck disable=SC1090
    source "$state"
    rm -f "$state"
    # shellcheck disable=SC2153
    if [ "$FLOATED" != "true" ]; then
        hyprctl dispatch movecursor "$MOUSE_X" "$MOUSE_Y"
        hyprctl dispatch togglefloating
        exit 0
    fi

    hyprctl dispatch resizeactive exact "$WINDOW_W" "$WINDOW_H"
    hyprctl dispatch moveactive exact "$WINDOW_X" "$WINDOW_Y"
else
    # ------------------------------
    # 进入伪全屏模式
    # ------------------------------
    # 1. 记录原始状态
    x=$(echo "$win" | jq -r '.at[0]')
    y=$(echo "$win" | jq -r '.at[1]')
    w=$(echo "$win" | jq -r '.size[0]')
    h=$(echo "$win" | jq -r '.size[1]')
    read mx my <<< "$(hyprctl cursorpos -j | jq -r '[.x, .y] | join(" ")')"


    # 写入文件
    cat > "$state" << EOF
WINDOW_X=$x
WINDOW_Y=$y
WINDOW_W=$w
WINDOW_H=$h
MOUSE_X=$mx
MOUSE_Y=$my
FLOATED=$floated
EOF

    # 2. 如果当前是平铺模式，先强制切到浮动
    [ "$floated" != "true" ] && hyprctl dispatch setfloating

    # 3. 强制移动到左上角并铺满屏幕
    hyprctl dispatch resizeactive  exact 100% 100%
    hyprctl dispatch moveactive exact 0 0
fi
