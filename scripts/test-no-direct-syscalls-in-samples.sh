#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SAMPLES_DIR="$ROOT_DIR/samples"

if [[ ! -d "$SAMPLES_DIR" ]]; then
  echo "[no-direct-syscalls] no samples directory; skipping"
  exit 0
fi

matches="$(rg -n --glob '**/*.aos' 'Call\(target=sys\.' "$SAMPLES_DIR" || true)"

if [[ -n "$matches" ]]; then
  echo "[no-direct-syscalls] FAIL: direct syscalls found in samples"
  echo "$matches"
  echo "[no-direct-syscalls] Samples must use AiVectra public API only."
  exit 1
fi

echo "[no-direct-syscalls] PASS"
