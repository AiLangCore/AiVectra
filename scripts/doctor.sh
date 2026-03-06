#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIRUN_BIN="${AIRUN_BIN:-$ROOT_DIR/.tools/airun}"
if [[ ! -x "$AIRUN_BIN" ]]; then
  AIRUN_BIN="${AIRUN_BIN_FALLBACK:-airun}"
fi

pass() { echo "[doctor] pass: $1"; }
fail() { echo "[doctor] fail: $1" >&2; }

has_failure=0
help_text="$("$AIRUN_BIN" --help 2>&1 || true)"
requires_prebuilt=0
if [[ "$help_text" != *".aos"* || "$help_text" != *"project-dir"* ]]; then
  requires_prebuilt=1
fi

if command -v "$AIRUN_BIN" >/dev/null 2>&1; then
  pass "airun available ($AIRUN_BIN)"
else
  fail "airun not found (set AIRUN_BIN or install airun)"
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

if [[ $has_failure -eq 0 ]]; then
  if [[ $requires_prebuilt -eq 1 ]]; then
    if [[ -f "$ROOT_DIR/src/AiVectra.Cli/app.aibc1" ]]; then
      if "$ROOT_DIR/scripts/aivectra" run "$ROOT_DIR/src/AiVectra.Cli/" debug snapshot >/dev/null 2>&1; then
        pass "AiVectra.Cli executes (prebuilt bytecode runtime)"
      else
        fail "AiVectra.Cli failed to execute (prebuilt bytecode runtime)"
        has_failure=1
      fi
    else
      echo "[doctor] warn: runtime requires prebuilt bytecode and no /src/AiVectra.Cli/app.aibc1 present"
      echo "[doctor] warn: build/publish bytecode artifacts before run/debug execution checks"
      pass "AiVectra.Cli runtime wiring checks deferred (missing prebuilt .aibc1)"
    fi
  else
    if "$ROOT_DIR/scripts/aivectra" run "$ROOT_DIR/samples/HelloName/" snapshot >/dev/null 2>&1; then
      pass "sample execution path works (HelloName snapshot)"
    else
      fail "sample execution path failed (HelloName snapshot)"
      has_failure=1
    fi
  fi
fi

if [[ $has_failure -ne 0 ]]; then
  exit 1
fi

echo "[doctor] environment ready"
