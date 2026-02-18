#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA_CLI="$ROOT_DIR/scripts/aivectra"

MODE="${1:-snapshot}"

case "$MODE" in
  snapshot)
    echo "[ui-debug] running non-interactive layout snapshots"
    exec "$AIVECTRA_CLI" run "$ROOT_DIR/src/AiVectra.Cli/" debug snapshot
    ;;
  live)
    echo "[ui-debug] running live HelloName app with change-only debug logs"
    exec "$AIVECTRA_CLI" run "$ROOT_DIR/samples/HelloName/"
    ;;
  replay)
    echo "[ui-debug] running deterministic input replay"
    exec "$AIVECTRA_CLI" run "$ROOT_DIR/src/AiVectra.Cli/" debug replay
    ;;
  *)
    echo "usage: $0 [snapshot|replay|live]" >&2
    exit 2
    ;;
esac
