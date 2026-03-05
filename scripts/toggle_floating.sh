#!/bin/bash
set -euo pipefail

win=$(hyprctl activewindow -j)
add=$(echo "$win" | jq -r '.address')
float=$(echo "$win" | jq -r '.floating')

cursor="/tmp/hypr/clients/$add/settiled/cursor"
active="/tmp/hypr/clients/$add/floating/active"
normalize="/tmp/hypr/clients/$add/floating/normalize"

[ -f "$cursor" ] && jq -r '[.x, .y] | join(" ")' "$cursor" | xargs -r hyprctl dispatch movecursor
hyprctl dispatch togglefloating
if [ "$float" = "true" ]; then
    echo "toggle unfloating"
    echo "$win" > "$normalize"
    /bin/rm -rf "$active"
else
    echo "toggle floating"
    mkdir -p "$(dirname "$cursor")"
    hyprctl cursorpos -j > "$cursor"
    [ "${1:-null}" == "null" ] && echo 1 > "$active"
fi
hyprctl dispatch focuswindow "address:$add"
