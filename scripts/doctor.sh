#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AILANG_BIN="${AILANG_BIN:-$ROOT_DIR/.tools/ailang}"
if [[ ! -x "$AILANG_BIN" ]]; then
  AILANG_BIN="${AILANG_BIN_FALLBACK:-ailang}"
fi

pass() { echo "[doctor] pass: $1"; }
fail() { echo "[doctor] fail: $1" >&2; }

has_failure=0
help_text="$("$AILANG_BIN" --help 2>&1 || true)"

if command -v "$AILANG_BIN" >/dev/null 2>&1; then
  pass "ailang available ($AILANG_BIN)"
else
  fail "ailang not found (set AILANG_BIN or install ailang)"
  has_failure=1
fi

if command -v python3 >/dev/null 2>&1; then
  pass "python3 available"
else
  fail "python3 not found (required by debug tooling scripts)"
  has_failure=1
fi

if command -v swift >/dev/null 2>&1; then
  pass "swift available (input injection capability)"
else
  echo "[doctor] warn: swift not found (input command unavailable)"
fi

if [[ "$help_text" == *".aos"* && "$help_text" == *"project-dir"* ]]; then
  pass "ailang supports source/project execution"
else
  echo "[doctor] warn: ailang appears to require prebuilt bytecode inputs"
fi

if [[ $has_failure -ne 0 ]]; then
  exit 1
fi

echo "[doctor] environment ready"
