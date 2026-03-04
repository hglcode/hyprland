#!/bin/bash
# 增强版手动伪全屏：支持平铺 -> 浮动 -> 全屏的自动切换

# 获取当前窗口地址和信息
ACTIVE_WIN=$(hyprctl activewindow -j)
ADDR=$(echo "$ACTIVE_WIN" | jq -r '.address')
if [ -z "$ADDR" ] || [ "$ADDR" == "null" ]; then
    exit 1
fi

# 解析当前窗口是否为浮动 (floating: true/false)
FLOATED=$(echo "$ACTIVE_WIN" | jq -r '.floating')

# 状态文件
STATE_DIR="/tmp/hypr_manual_fullscreen"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/$ADDR"

if [ -f "$STATE_FILE" ]; then
    # ------------------------------
    # 退出伪全屏模式
    # ------------------------------
    # shellcheck disable=SC1090
    source "$STATE_FILE"

    rm -f "$STATE_FILE"
    if [ "$FLOATED" != "true" ]; then
        echo "x=$MOUSE_X y=$MOUSE_Y"
        hyprctl dispatch movecursor $MOUSE_X $MOUSE_Y
        hyprctl dispatch togglefloating
        exit 0
    fi

    hyprctl dispatch resizeactive exact $ORIG_W $ORIG_H
    hyprctl dispatch moveactive exact $ORIG_X $ORIG_Y
else
    # ------------------------------
    # 进入伪全屏模式
    # ------------------------------
    # 1. 记录原始状态
    ORIG_X=$(echo "$ACTIVE_WIN" | jq -r '.at[0]')
    ORIG_Y=$(echo "$ACTIVE_WIN" | jq -r '.at[1]')
    ORIG_W=$(echo "$ACTIVE_WIN" | jq -r '.size[0]')
    ORIG_H=$(echo "$ACTIVE_WIN" | jq -r '.size[1]')
    read MOUSE_X MOUSE_Y <<< "$(hyprctl cursorpos | tr ',' ' ')"

    # 写入文件
    cat > "$STATE_FILE" << EOF
ORIG_X=$ORIG_X
ORIG_Y=$ORIG_Y
ORIG_W=$ORIG_W
ORIG_H=$ORIG_H
MOUSE_X=$MOUSE_X
MOUSE_Y=$MOUSE_Y
FLOATED=$FLOATED
EOF

    # 2. 如果当前是平铺模式，先强制切到浮动
    if [ "$FLOATED" != "true" ]; then
        hyprctl dispatch setfloating
        # 稍微等待一下，确保状态切换完成 (视情况可调整 sleep 时间)
        #sleep 0.1
    fi

    # 3. 强制移动到左上角并铺满屏幕
    hyprctl dispatch resizeactive  exact 100% 100%
    hyprctl dispatch moveactive exact 0 0
fi
