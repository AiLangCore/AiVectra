#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "[test-all] cli contract"
"$ROOT_DIR/scripts/test-cli-contract.sh"

echo "[test-all] golden ui"
"$ROOT_DIR/scripts/test-golden-ui.sh"

echo "[test-all] interactive svg"
"$ROOT_DIR/scripts/test-interactive-svg-mvp.sh"

echo "[test-all] hello-name behavior"
"$ROOT_DIR/scripts/test-hello-name-behavior.sh"

echo "[test-all] debug ci parity"
"$ROOT_DIR/scripts/test-debug-ci-parity.sh"

echo "[test-all] no direct syscalls in samples"
"$ROOT_DIR/scripts/test-no-direct-syscalls-in-samples.sh"

if [[ "${AIVECTRA_SCREENSHOT_TEST:-0}" == "1" ]]; then
  echo "[test-all] screenshot reality"
  "$ROOT_DIR/scripts/test-screenshot-debug-reality.sh"
else
  echo "[test-all] screenshot reality skipped (set AIVECTRA_SCREENSHOT_TEST=1 to enable)"
fi

echo "[test-all] all checks passed"
