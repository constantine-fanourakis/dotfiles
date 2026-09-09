#!/usr/bin/env bash
#
# Fetch the Bing image of the day and set it as the wallpaper.
#
#   - Keeps the last $KEEP days in $DIR, named by Bing's own publish date.
#   - $DIR/current.jpg is a symlink to today's image; hyprpaper.conf points at
#     that stable path, so the wallpaper survives restarts and reboots.
#   - Downloads to a temp file in the same directory and only moves it into
#     place after validating it, so a partial, failed, or offline fetch can
#     never leave a corrupt image or clobber the wallpaper already in use.
#   - Safe to run when logged out: the file is updated and simply applied at
#     next login, since hyprpaper reads the symlink from its config.
#
set -euo pipefail

DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpapers/bing"
KEEP=7
API='https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US'
CURL=(curl -sfL --max-time 60 --retry 3 --retry-delay 5)

log() { printf '%s\n' "$*" >&2; }

mkdir -p "$DIR"

meta=$("${CURL[@]}" "$API") || { log "bing: metadata fetch failed"; exit 0; }

read -r date urlbase < <(
  printf '%s' "$meta" | python3 -c '
import json,sys
i = json.load(sys.stdin)["images"][0]
print(i["startdate"], i["urlbase"])'
) || { log "bing: could not parse metadata"; exit 0; }

target="$DIR/$date.jpg"

if [[ ! -s "$target" ]]; then
    tmp=$(mktemp "$DIR/.tmp.XXXXXX")          # same dir => mv is atomic
    trap 'rm -f "$tmp"' EXIT

    # UHD is 3840x2160; fall back to 1080p on the rare day it is missing.
    if ! "${CURL[@]}" -o "$tmp" "https://www.bing.com${urlbase}_UHD.jpg"; then
        log "bing: UHD unavailable, falling back to 1920x1080"
        "${CURL[@]}" -o "$tmp" "https://www.bing.com${urlbase}_1920x1080.jpg" \
            || { log "bing: download failed"; exit 0; }
    fi

    # Validate before installing: a captive portal or error page would
    # otherwise be written straight over the wallpaper.
    case "$(file -b --mime-type "$tmp")" in
        image/jpeg) ;;
        *) log "bing: downloaded file is not a JPEG, discarding"; exit 0 ;;
    esac

    chmod 644 "$tmp"          # mktemp creates 0600; wallpapers are not secrets
    mv -f "$tmp" "$target"
    trap - EXIT
    log "bing: fetched $date"
fi

ln -sfn "$target" "$DIR/current.jpg"

# Keep only the newest $KEEP dated images.
find "$DIR" -maxdepth 1 -name '2*.jpg' -type f -printf '%f\n' \
    | sort -r | tail -n +$((KEEP + 1)) \
    | while IFS= read -r old; do rm -f -- "$DIR/$old"; done

# Apply live only if hyprpaper is actually up.
if pgrep -x hyprpaper >/dev/null 2>&1; then
    hyprctl hyprpaper wallpaper ",$DIR/current.jpg" >/dev/null 2>&1 \
        || log "bing: hyprpaper did not accept the wallpaper"
fi
