#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export AIVECTRA_USE_MACOS_BUNDLE="${AIVECTRA_USE_MACOS_BUNDLE:-0}"
if [[ -z "${AILANG_BIN:-}" ]]; then
  if [[ -x "$ROOT_DIR/../AiLang/tools/ailang" ]]; then
    export AILANG_BIN="$ROOT_DIR/../AiLang/tools/ailang"
  elif [[ -x "$ROOT_DIR/.tools/ailang" ]]; then
    export AILANG_BIN="$ROOT_DIR/.tools/ailang"
  elif [[ -x "${HOME}/.ailang/bin/ailang" ]]; then
    export AILANG_BIN="${HOME}/.ailang/bin/ailang"
  fi
fi

echo "[test-all] cli contract"
"$ROOT_DIR/scripts/test-cli-contract.sh"

echo "[test-all] golden visual contract"
"$ROOT_DIR/scripts/test-golden-ui.sh"

echo "[test-all] interactive svg"
"$ROOT_DIR/scripts/test-interactive-svg-mvp.sh"

echo "[test-all] sample structure"
"$ROOT_DIR/scripts/test-sample-structure.sh"

echo "[test-all] hello-name behavior"
"$ROOT_DIR/scripts/test-hello-name-behavior.sh"

echo "[test-all] debug ci parity"
"$ROOT_DIR/scripts/test-debug-ci-parity.sh"

echo "[test-all] package surface"
"$ROOT_DIR/scripts/test-package-surface.sh"

if [[ "${AIVECTRA_ARCHITECTURE_TEST:-0}" == "1" ]]; then
  echo "[test-all] architecture lint"
  "$ROOT_DIR/scripts/test-no-direct-syscalls-in-samples.sh"
else
  echo "[test-all] architecture lint skipped (set AIVECTRA_ARCHITECTURE_TEST=1 to enable)"
fi

if [[ "${AIVECTRA_SCREENSHOT_TEST:-0}" == "1" ]]; then
  echo "[test-all] screenshot visual parity"
  "$ROOT_DIR/scripts/test-screenshot-debug-reality.sh"
else
  echo "[test-all] screenshot visual parity skipped (set AIVECTRA_SCREENSHOT_TEST=1 to enable)"
fi

echo "[test-all] all checks passed"
