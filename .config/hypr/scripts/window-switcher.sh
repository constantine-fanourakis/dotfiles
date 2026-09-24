#!/usr/bin/env bash
#
# Pick a window from all workspaces and focus it.
#
# Rows are "address<TAB>label"; fuzzel shows only the label (--with-nth=2) and
# returns the row index (--index), so the address is recovered by position
# rather than by matching the label. Titles are arbitrary user text and are
# frequently duplicated, which makes matching on them unreliable.
#
set -euo pipefail

mapfile -t rows < <(hyprctl clients -j | python3 -c '
import json, sys

wins = [w for w in json.load(sys.stdin)
        if w.get("mapped") and w["workspace"]["id"] > 0]
wins.sort(key=lambda w: (w["workspace"]["id"], w["class"].lower()))

for w in wins:
    title = " ".join(w["title"].split())[:70]
    print("%s\t%s  %-18s %s" % (w["address"], w["workspace"]["id"], w["class"][:18], title))
')

(( ${#rows[@]} )) || exit 0

idx=$(printf '%s\n' "${rows[@]}" \
      | fuzzel --dmenu --index --with-nth=2 --prompt='window: ') || exit 0
[[ -n $idx ]] || exit 0

addr=${rows[idx]%%$'\t'*}
hyprctl dispatch "hl.dsp.focus({ window = 'address:$addr' })" >/dev/null
