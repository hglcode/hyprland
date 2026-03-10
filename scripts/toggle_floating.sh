#!/bin/sh
set -u

win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')
float=$(echo "$win" | jq -r '.floating')
wid=$(hyprctl activeworkspace -j | jq '.id')

settiled="/tmp/hypr/clients/$add/settiled/settiled"
active="/tmp/hypr/clients/$add/floating/active"
normalize="/tmp/hypr/clients/$add/floating/normalize"

[ "$float" = "true" ] && [ -f "$settiled" ] && {
    read -r x y w h << EOF
        $(jq -r '.at[], .size[]' "$settiled" | tr '\n' ' ')
EOF
    hyprctl dispatch movecursor $((x + w / 2)) $((y + h / 2))
}

hyprctl dispatch togglefloating
if [ "$float" = "true" ]; then
    mkdir -p "$(dirname "$normalize")"
    echo "$win" > "$normalize"
    /bin/rm -rf "$active" > /dev/null 2> /dev/null || true

    # TODO: 如果浮动层有窗口，聚焦到浮动层最上层的窗口
    # 如果浮动层有窗口，聚焦到浮动层最上层的窗口

    # 获取当前工作区的所有浮动窗口，按focusHistoryID排序，取最小的（最上层）
    top_add=$(hyprctl clients -j | jq ".[] | select(.workspace.id == $wid and .floating == true)" | jq -s -r 'sort_by(.focusHistoryID) | first | .address')

    # 如果有浮动窗口且不是当前窗口，聚焦到该窗口
    if [ -n "$top_add" ] && [ "$top_add" != "$add" ]; then
        add="$top_add"
    fi
else
    mkdir -p "$(dirname "$settiled")"
    echo "$win" > "$settiled"
    [ "${1:-null}" = "null" ] && mkdir -p "$(dirname "$active")" && touch "$active" && echo "floating"
fi
hyprctl dispatch bringactivetotops
hyprctl dispatch focuswindow "address:$add"
