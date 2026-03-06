#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"
AIRUN_BIN="${AIRUN_BIN:-$ROOT_DIR/.tools/airun}"
HELP_TEXT="$("$AIRUN_BIN" --help 2>&1 || true)"
REQUIRES_PREBUILT=0
if [[ "$HELP_TEXT" != *".aos"* || "$HELP_TEXT" != *"project-dir"* ]]; then
  REQUIRES_PREBUILT=1
fi

if [[ $REQUIRES_PREBUILT -eq 1 && ! -f "$ROOT_DIR/samples/HelloName/app.aibc1" ]]; then
  echo "hello-name run-mode checks skipped: runtime requires prebuilt /samples/HelloName/app.aibc1"
  exit 0
fi

set +e
out_replay="$("$AIVECTRA" run "$ROOT_DIR/samples/HelloName/" replay 2>&1)"
rc_replay=$?
set -e
if [[ $rc_replay -ne 0 ]]; then
  echo "hello-name replay run failed (rc=$rc_replay)" >&2
  printf "%s\n" "$out_replay" >&2
  exit 1
fi

echo "$out_replay" | rg -q "Err#|vm_err" && {
  echo "hello-name replay run reported error output" >&2
  exit 1
}

set +e
out_snapshot="$("$AIVECTRA" run "$ROOT_DIR/samples/HelloName/" snapshot 2>&1)"
rc_snapshot=$?
set -e
if [[ $rc_snapshot -ne 0 ]]; then
  echo "hello-name snapshot run failed (rc=$rc_snapshot)" >&2
  printf "%s\n" "$out_snapshot" >&2
  exit 1
fi

echo "$out_snapshot" | rg -q "Err#|vm_err" && {
  echo "hello-name snapshot run reported error output" >&2
  exit 1
}

echo "hello-name run-mode checks passed"
