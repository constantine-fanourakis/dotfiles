#!/usr/bin/env bash
#
# waybar control for hyprsunset: report state as JSON, and toggle between a
# warm and a neutral colour temperature.
#
# State is derived from the reported temperature rather than tracked
# separately. hyprsunset keeps reporting the last temperature set even after
# `identity`, so `identity` is indistinguishable from a neutral filter;
# toggling between two temperatures keeps the reported value authoritative.
set -euo pipefail

WARM=3500
NEUTRAL=6000     # matches hyprsunset's own startup default
SIGNAL=8          # must match "signal" in the waybar module

temp() { hyprctl hyprsunset temperature 2>/dev/null | head -1; }

case "${1:-status}" in
status)
    t=$(temp)
    if [[ ! $t =~ ^[0-9]+$ ]]; then
        printf '{"text":"","tooltip":"hyprsunset not running","class":"off"}\n'
        exit 0
    fi
    if (( t < NEUTRAL )); then
        printf '{"text":"","tooltip":"Night light on - %sK","class":"on"}\n' "$t"
    else
        printf '{"text":"","tooltip":"Night light off - %sK","class":"off"}\n' "$t"
    fi
    ;;
toggle)
    t=$(temp)
    [[ $t =~ ^[0-9]+$ ]] || exit 0
    if (( t < NEUTRAL )); then
        hyprctl hyprsunset temperature "$NEUTRAL" >/dev/null
    else
        hyprctl hyprsunset temperature "$WARM" >/dev/null
    fi
    pkill -RTMIN+"$SIGNAL" waybar || true
    ;;
*)
    echo "usage: $0 {status|toggle}" >&2; exit 1 ;;
esac
