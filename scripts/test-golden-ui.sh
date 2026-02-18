#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"
GOLDEN_DIR="$ROOT_DIR/examples/golden/ui-components"

actual_snapshot="$(mktemp)"
actual_replay="$(mktemp)"
trap 'rm -f "$actual_snapshot" "$actual_replay"' EXIT

"$AIVECTRA" run "$ROOT_DIR/src/AiVectra.Cli/" debug snapshot > "$actual_snapshot"
"$AIVECTRA" run "$ROOT_DIR/src/AiVectra.Cli/" debug replay > "$actual_replay"

diff -u "$GOLDEN_DIR/snapshot.expected" "$actual_snapshot"
diff -u "$GOLDEN_DIR/replay.expected" "$actual_replay"

echo "golden ui checks passed"
