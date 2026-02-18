#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"
GOLDEN_DIR="$ROOT_DIR/examples/golden/interactive-svg"

actual_snapshot="$(mktemp)"
actual_replay="$(mktemp)"
trap 'rm -f "$actual_snapshot" "$actual_replay"' EXIT

"$AIVECTRA" run "$ROOT_DIR/samples/InteractiveSvgMvp/" snapshot > "$actual_snapshot"
"$AIVECTRA" run "$ROOT_DIR/samples/InteractiveSvgMvp/" replay > "$actual_replay"

diff -u "$GOLDEN_DIR/snapshot.expected" "$actual_snapshot"
diff -u "$GOLDEN_DIR/replay.expected" "$actual_replay"

echo "interactive svg mvp checks passed"
