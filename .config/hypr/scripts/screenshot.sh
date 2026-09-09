#!/usr/bin/env bash
# Screenshot helper: copies to clipboard AND saves to ~/Pictures/Screenshots
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

case "${1:-region}" in
    region)
        geom=$(slurp) || exit 0        # user pressed Esc
        grim -g "$geom" "$FILE"
        ;;
    output)
        grim "$FILE"
        ;;
    *)
        echo "usage: $0 {region|output}" >&2
        exit 1
        ;;
esac

# wl-copy forks a resident daemon to serve the clipboard and inherits this
# script's stdio. Redirect it, or callers capturing output block on EOF.
wl-copy --type image/png < "$FILE" >/dev/null 2>&1

notify-send "Screenshot saved" "$(basename "$FILE")" -i "$FILE" -t 3000 >/dev/null 2>&1 || true
