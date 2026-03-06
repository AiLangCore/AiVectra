#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"

usage() {
  cat <<EOF
usage: ./scripts/capture-debug-scene.sh <app-path> <out-dir> [window-title] [timeout-ms]

example:
  ./scripts/capture-debug-scene.sh ./samples/HelloWorld/ ./.artifacts/debug/hw_scene_cap "AiVectra Hello" 2000
EOF
}

if [[ $# -lt 2 ]]; then
  usage >&2
  exit 2
fi

APP_PATH="$1"
OUT_DIR="$2"
WINDOW_TITLE="${3:-AiVectra Hello}"
TIMEOUT_MS="${4:-2000}"

if ! [[ "$TIMEOUT_MS" =~ ^[0-9]+$ ]]; then
  echo "timeout-ms must be an integer (milliseconds)" >&2
  exit 2
fi

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

STDOUT_LOG="$OUT_DIR/scene.stdout.log"
INPUT_LOG="$OUT_DIR/scene.input.log"

set +e
"$AIVECTRA" debug --debug-mode scene --out "$OUT_DIR" "$APP_PATH" >"$STDOUT_LOG" 2>&1 &
APP_PID=$!
set -e

sleep 0.9
"$AIVECTRA" input --window "$WINDOW_TITLE" --events "wait:80;close" >"$INPUT_LOG" 2>&1 || true

wait_seconds="$(awk "BEGIN { printf \"%.3f\", $TIMEOUT_MS / 1000 }")"
elapsed=0
step=0.1
while kill -0 "$APP_PID" 2>/dev/null; do
  if awk "BEGIN { exit !($elapsed >= $wait_seconds) }"; then
    kill "$APP_PID" >/dev/null 2>&1 || true
    wait "$APP_PID" 2>/dev/null || true
    echo "scene capture timed out after ${TIMEOUT_MS}ms" >&2
    break
  fi
  sleep "$step"
  elapsed="$(awk "BEGIN { printf \"%.3f\", $elapsed + $step }")"
done

if kill -0 "$APP_PID" 2>/dev/null; then
  kill "$APP_PID" >/dev/null 2>&1 || true
  wait "$APP_PID" 2>/dev/null || true
fi

required_files=(
  "$OUT_DIR/config.toml"
  "$OUT_DIR/events.toml"
  "$OUT_DIR/syscalls.toml"
)

missing=0
for f in "${required_files[@]}"; do
  if [[ ! -s "$f" ]]; then
    echo "missing required artifact: $f" >&2
    missing=1
  fi
done

if [[ $missing -ne 0 ]]; then
  echo "scene capture failed artifact gate" >&2
  exit 3
fi

echo "scene capture ok: $OUT_DIR"
