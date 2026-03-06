#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"
SHOT_TOOL="/Users/toddhenderson/.codex/skills/screenshot/scripts/take_screenshot.py"

OUT_DIR="${1:-$ROOT_DIR/artifacts}"
mkdir -p "$OUT_DIR"

APP_LOG="$OUT_DIR/live_frame.log"
SHOT_PATH_FILE="$OUT_DIR/live_window_shot.path"

: > "$APP_LOG"
"$AIVECTRA" debug --debug-mode live "$ROOT_DIR/samples/HelloName/" >"$APP_LOG" 2>&1 &
APP_PID=$!
sleep 1

WIN_LINE="$(python3 "$SHOT_TOOL" --window-name "AiVectra Hello Name" --list-windows | head -n1)"
if [[ -z "$WIN_LINE" || "$WIN_LINE" == no\ matching\ windows\ found* ]]; then
  kill "$APP_PID" >/dev/null 2>&1 || true
  wait "$APP_PID" 2>/dev/null || true
  echo "no matching window found" >&2
  exit 2
fi

GEO="$(printf '%s\n' "$WIN_LINE" | sed -E 's/.*\t([0-9]+x[0-9]+\+[0-9]+\+[0-9]+)$/\1/')"
W="${GEO%%x*}"
REST="${GEO#*x}"
H="${REST%%+*}"
XPLUS="${GEO#*+}"
X="${XPLUS%%+*}"
Y="${GEO##*+}"
X="${X%%.*}"
Y="${Y%%.*}"
W="${W%%.*}"
H="${H%%.*}"

python3 "$SHOT_TOOL" --region "${X},${Y},${W},${H}" --mode temp >"$SHOT_PATH_FILE"
SHOT="$(head -n1 "$SHOT_PATH_FILE")"

kill "$APP_PID" >/dev/null 2>&1 || true
wait "$APP_PID" 2>/dev/null || true

python3 "$ROOT_DIR/scripts/generate-debug-render-svg.py" \
  --input-log "$APP_LOG" \
  --frame-id 1 \
  --out "artifacts/debug_render_live_frame1.svg" >/dev/null

qlmanage -t -s 640 -o /tmp "$ROOT_DIR/artifacts/debug_render_live_frame1.svg" >/dev/null 2>&1

SVG_PNG="/tmp/debug_render_live_frame1.svg.png"
CLIENT_PNG="$OUT_DIR/live_client.png"
SIDE_PNG="$OUT_DIR/live_vs_debug_side_by_side.png"
DIFF_PNG="$OUT_DIR/live_vs_debug_diff.png"
MEAN_TXT="$OUT_DIR/live_vs_debug_diff_mean.txt"

# Window capture is 2x on Retina. Client area is 640x360 at y offset 32.
magick "$SHOT" -crop 1280x720+0+64 +repage -resize 640x360\! "$CLIENT_PNG"
magick "$CLIENT_PNG" "$SVG_PNG" +append "$SIDE_PNG"
magick "$CLIENT_PNG" "$SVG_PNG" -compose difference -composite -colorspace Gray -auto-level "$DIFF_PNG"
magick "$DIFF_PNG" -format "%[fx:mean]" info: > "$MEAN_TXT"

printf '[aivectra.compare] window="%s"\n' "$WIN_LINE"
printf '[aivectra.compare] shot="%s"\n' "$SHOT"
printf '[aivectra.compare] client="%s"\n' "$CLIENT_PNG"
printf '[aivectra.compare] side="%s"\n' "$SIDE_PNG"
printf '[aivectra.compare] diff="%s"\n' "$DIFF_PNG"
printf '[aivectra.compare] mean_diff=%s\n' "$(cat "$MEAN_TXT")"
