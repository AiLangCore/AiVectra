#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"
OUT_DIR="$ROOT_DIR/.artifacts/debug/ci-parity"
AIRUN_BIN="${AIRUN_BIN:-$ROOT_DIR/.tools/airun}"
HELP_TEXT="$("$AIRUN_BIN" --help 2>&1 || true)"
REQUIRES_PREBUILT=0
if [[ "$HELP_TEXT" != *".aos"* || "$HELP_TEXT" != *"project-dir"* ]]; then
  REQUIRES_PREBUILT=1
fi

if [[ $REQUIRES_PREBUILT -eq 1 ]]; then
  echo "debug ci parity skipped: fixture debug app is source-based and requires non-native-c debug frontend"
  exit 0
fi

"$ROOT_DIR/scripts/bootstrap-golden-publish-fixtures.sh" >/dev/null
rm -rf "$OUT_DIR"

"$AIVECTRA" debug "$ROOT_DIR/examples/debug/apps/debug_minimal.aos" --out "$OUT_DIR" >/dev/null

if [[ ! -d "$OUT_DIR" ]]; then
  echo "debug ci parity skipped: runtime did not emit debug artifact bundle (--out unsupported in this build)"
  exit 0
fi

for f in config.toml vm_trace.toml state_snapshots.toml syscalls.toml events.toml diagnostics.toml; do
  if [[ ! -f "$OUT_DIR/$f" ]]; then
    echo "missing debug artifact: $OUT_DIR/$f" >&2
    exit 1
  fi
done

if find "$OUT_DIR" -maxdepth 1 -name '*.aos' | rg -q .; then
  echo "unexpected .aos data artifacts found in $OUT_DIR" >&2
  find "$OUT_DIR" -maxdepth 1 -name '*.aos' >&2
  exit 1
fi

echo "debug ci parity: pass"
