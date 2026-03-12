#!/bin/sh
set -eu
pdir="$HOME/Pictures/screenshot"
mkdir -p "$pdir"
hyprshot -m region --raw | satty -o "$pdir/$(date '+%Y%m%d%H%M%S').png" --copy-command  wl-copy --save-after-copy -f - --actions-on-enter save-to-clipboard,exit
