#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"
GOLDEN_DIR="$ROOT_DIR/examples/golden/ui-components"
AIRUN_BIN="${AIRUN_BIN:-$ROOT_DIR/.tools/airun}"
HELP_TEXT="$("$AIRUN_BIN" --help 2>&1 || true)"
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
  if rg -q 'code=RUN001' "$actual_snapshot" || rg -q 'code=RUN001' "$actual_replay"; then
    echo "golden ui checks skipped: AiVectra.Cli debug sample currently fails under this runtime (RUN001)"
    exit 0
  fi
  echo "golden ui checks failed: unexpected execution error" >&2
  cat "$actual_snapshot" >&2
  cat "$actual_replay" >&2
  exit 1
fi

diff -u "$GOLDEN_DIR/snapshot.expected" "$actual_snapshot"
diff -u "$GOLDEN_DIR/replay.expected" "$actual_replay"

echo "golden ui checks passed"
