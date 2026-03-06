#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA_CLI="$ROOT_DIR/scripts/aivectra"

MODE="${1:-snapshot}"
APP_PATH="${2:-}"

case "$MODE" in
  snapshot)
    echo "[ui-debug] running deterministic snapshot capture"
    if [[ -z "$APP_PATH" ]]; then
      APP_PATH="$ROOT_DIR/examples/debug/apps/debug_minimal.aos"
    fi
    exec "$AIVECTRA_CLI" debug "$APP_PATH" --out "$ROOT_DIR/.artifacts/debug/ui-snapshot"
    ;;
  live)
    echo "[ui-debug] running live app debug capture"
    if [[ -z "$APP_PATH" ]]; then
      APP_PATH="$ROOT_DIR/samples/HelloName/src/app.aos"
    fi
    exec "$AIVECTRA_CLI" debug "$APP_PATH" --out "$ROOT_DIR/.artifacts/debug/ui-live"
    ;;
  replay)
    echo "[ui-debug] running replay fixture capture"
    if [[ -z "$APP_PATH" ]]; then
      APP_PATH="$ROOT_DIR/examples/debug/apps/debug_minimal.aos"
    fi
    exec "$AIVECTRA_CLI" debug "$APP_PATH" --events "$ROOT_DIR/examples/debug/events/minimal.events.toml" --out "$ROOT_DIR/.artifacts/debug/ui-replay"
    ;;
  *)
    echo "usage: $0 [snapshot|replay|live] [app.aos]" >&2
    exit 2
    ;;
esac
