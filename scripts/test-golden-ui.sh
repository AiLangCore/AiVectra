#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"
GOLDEN_DIR="$ROOT_DIR/examples/golden/ui-components"
AILANG_BIN="${AILANG_BIN:-$ROOT_DIR/.tools/ailang}"
HELP_TEXT="$("$AILANG_BIN" --help 2>&1 || true)"
REQUIRES_PREBUILT=0
if [[ "$HELP_TEXT" != *".aos"* || "$HELP_TEXT" != *"project-dir"* ]]; then
  REQUIRES_PREBUILT=1
fi

if [[ $REQUIRES_PREBUILT -eq 1 && ! -f "$ROOT_DIR/src/AiVectra.Cli/app.aibc1" ]]; then
  echo "golden ui checks skipped: runtime requires prebuilt /src/AiVectra.Cli/app.aibc1"
  exit 0
fi

actual_snapshot="$(mktemp)"
actual_replay="$(mktemp)"
trap 'rm -f "$actual_snapshot" "$actual_replay"' EXIT

set +e
"$AIVECTRA" run "$ROOT_DIR/src/AiVectra.Cli/" debug snapshot > "$actual_snapshot" 2>&1
rc_snapshot=$?
"$AIVECTRA" run "$ROOT_DIR/src/AiVectra.Cli/" debug replay > "$actual_replay" 2>&1
rc_replay=$?
set -e

if [[ $rc_snapshot -ne 0 || $rc_replay -ne 0 ]]; then
  echo "golden visual contract failed: execution error" >&2
  cat "$actual_snapshot" >&2
  cat "$actual_replay" >&2
  exit 1
fi

diff -u "$GOLDEN_DIR/snapshot.expected" "$actual_snapshot"
diff -u "$GOLDEN_DIR/replay.expected" "$actual_replay"

echo "golden visual contract passed"
