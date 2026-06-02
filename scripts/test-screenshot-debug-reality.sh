#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"

resolve_screenshot_tool() {
  if [[ -n "${AIVECTRA_SCREENSHOT_TOOL:-}" ]]; then
    if [[ ! -f "$AIVECTRA_SCREENSHOT_TOOL" ]]; then
      echo "configured screenshot capture tool does not exist: $AIVECTRA_SCREENSHOT_TOOL" >&2
      exit 2
    fi
    printf '%s\n' "$AIVECTRA_SCREENSHOT_TOOL"
    return
  fi

  local codex_home="${CODEX_HOME:-$HOME/.codex}"
  local candidate="$codex_home/skills/screenshot/scripts/take_screenshot.py"
  if [[ -f "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return
  fi

  echo "missing screenshot capture tool" >&2
  echo "set AIVECTRA_SCREENSHOT_TOOL=/path/to/take_screenshot.py or install the Codex screenshot skill" >&2
  exit 2
}

resolve_permission_tool() {
  if [[ -n "${AIVECTRA_SCREENSHOT_PERMISSION_TOOL:-}" ]]; then
    if [[ ! -f "$AIVECTRA_SCREENSHOT_PERMISSION_TOOL" ]]; then
      echo "configured screenshot permission tool does not exist: $AIVECTRA_SCREENSHOT_PERMISSION_TOOL" >&2
      exit 2
    fi
    printf '%s\n' "$AIVECTRA_SCREENSHOT_PERMISSION_TOOL"
    return
  fi

  local codex_home="${CODEX_HOME:-$HOME/.codex}"
  local candidate="$codex_home/skills/screenshot/scripts/ensure_macos_permissions.sh"
  if [[ -f "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return
  fi

  printf '%s\n' ""
}

SHOT_TOOL="$(resolve_screenshot_tool)"
PERM_TOOL="$(resolve_permission_tool)"

# Read canonical layout line from deterministic snapshot output.
out_snapshot="$($AIVECTRA run "$ROOT_DIR/test-fixtures/HelloName/" snapshot)"
layout_line="$(printf '%s\n' "$out_snapshot" | rg '\[aivectra\] layout panel=' | head -n1)"
if [[ -z "$layout_line" ]]; then
  echo "missing layout line from snapshot output" >&2
  exit 2
fi

app_log="$(mktemp)"
shot_paths="$(mktemp)"
cleanup() {
  if [[ -n "${APP_PID:-}" ]]; then
    kill "$APP_PID" >/dev/null 2>&1 || true
    wait "$APP_PID" 2>/dev/null || true
  fi
  rm -f "$app_log" "$shot_paths"
}
trap cleanup EXIT

$AIVECTRA run "$ROOT_DIR/test-fixtures/HelloName/" >"$app_log" 2>&1 &
APP_PID=$!
sleep 2

# Permission preflight when a host-specific checker is available. The capture
# step below still fails with diagnostics if the OS blocks screenshot access.
if [[ -n "$PERM_TOOL" ]]; then
  bash "$PERM_TOOL" >/tmp/aivectra-screen-perm.log 2>&1
fi

capture_ok=0

if python3 "$SHOT_TOOL" --window-name "AiVectra Hello Name" --mode temp > "$shot_paths" 2>/tmp/aivectra-shot.err; then
  capture_ok=1
else
  if python3 "$SHOT_TOOL" --window-name "Hello Name" --mode temp > "$shot_paths" 2>/tmp/aivectra-shot.err; then
    capture_ok=1
  else
    # Last-resort fallback: active window capture.
    if python3 "$SHOT_TOOL" --active-window --mode temp > "$shot_paths" 2>/tmp/aivectra-shot.err; then
      capture_ok=1
    fi
  fi
fi

if [[ "$capture_ok" -ne 1 ]]; then
  echo "failed to capture screenshot window; diagnostics:" >&2
  python3 "$SHOT_TOOL" --list-windows --window-name "Hello Name" || true
  cat /tmp/aivectra-shot.err >&2 || true
  exit 2
fi

shot="$(head -n1 "$shot_paths")"
if [[ -z "$shot" || ! -f "$shot" ]]; then
  echo "screenshot path missing after capture" >&2
  exit 2
fi

python3 "$ROOT_DIR/scripts/verify_debug_vs_screenshot.py" \
  --image "$shot" \
  --layout-line "$layout_line"

echo "screenshot/debug reality checks passed"
