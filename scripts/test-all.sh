#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export AIVECTRA_USE_MACOS_BUNDLE="${AIVECTRA_USE_MACOS_BUNDLE:-0}"

cleanup_fixture_packages() {
  find "$ROOT_DIR/test-fixtures" -type d -name .ailang -prune -exec rm -rf {} +
  find "$ROOT_DIR/test-fixtures" -type f -name ailang.lock.toml -delete
}

trap cleanup_fixture_packages EXIT
cleanup_fixture_packages

if [[ -z "${AILANG_BIN:-}" ]]; then
  if [[ -x "$ROOT_DIR/../AiLang/tools/ailang" ]]; then
    export AILANG_BIN="$ROOT_DIR/../AiLang/tools/ailang"
  elif [[ -x "$ROOT_DIR/.tools/ailang" ]]; then
    export AILANG_BIN="$ROOT_DIR/.tools/ailang"
  elif [[ -x "${HOME}/.ailang/bin/ailang" ]]; then
    export AILANG_BIN="${HOME}/.ailang/bin/ailang"
  fi
fi

if [[ -z "${AILANG_PACKAGE_REGISTRY:-}" && -d "$ROOT_DIR/../ailang-packages/packages" ]]; then
  export AILANG_PACKAGE_REGISTRY="$ROOT_DIR/../ailang-packages"
fi

echo "[test-all] documentation taxonomy"
bash "$ROOT_DIR/scripts/check-doc-taxonomy.sh"

echo "[test-all] fixture package restore"
while IFS= read -r project_file; do
  fixture_dir="$(dirname "$project_file")"
  if grep -Eq 'Include#|Include\(' "$project_file"; then
    (cd "$fixture_dir" && "$AILANG_BIN" package restore >/dev/null)
  fi
done < <(find "$ROOT_DIR/test-fixtures" -name project.aiproj -type f | sort)

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

echo "[test-all] macOS run bundle"
"$ROOT_DIR/scripts/test-macos-run-bundle.sh"

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
