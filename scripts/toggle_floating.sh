#!/bin/sh
set -eu

win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')
float=$(echo "$win" | jq -r '.floating')

cursor="/tmp/hypr/clients/$add/settiled/cursor"
active="/tmp/hypr/clients/$add/floating/active"
normalize="/tmp/hypr/clients/$add/floating/normalize"

[ -f "$cursor" ] && jq -r '[.x, .y] | join(" ")' "$cursor" | xargs -r hyprctl dispatch movecursor
hyprctl dispatch togglefloating
if [ "$float" = "true" ]; then
    echo "$win" > "$normalize"
    /bin/rm -rf "$active" > /dev/null 2> /dev/null || true

    # TODO: 如果浮动层有窗口，聚焦到浮动层最上层的窗口
    # 如果浮动层有窗口，聚焦到浮动层最上层的窗口
    # 获取当前工作区ID
    wid=$(hyprctl activeworkspace -j | jq '.id')

    # 获取当前工作区的所有浮动窗口，按focusHistoryID排序，取最小的（最上层）
    top_add=$(hyprctl clients -j | jq ".[] | select(.workspace.id == $wid and .floating == true) | {address: .address, focusHistoryID: .focusHistoryID}" | jq -s -r 'sort_by(.focusHistoryID) | first | .address')

    # 如果有浮动窗口且不是当前窗口，聚焦到该窗口
    if [ -n "$top_add" ] && [ "$top_add" != "$add" ]; then
        add="$top_add"
    fi
else
    mkdir -p "$(dirname "$cursor")"
    hyprctl cursorpos -j > "$cursor"
    [ "${1:-null}" = "null" ] && echo 1 > "$active"
fi
hyprctl dispatch focuswindow "address:$add"
hyprctl dispatch bringactivetotop
