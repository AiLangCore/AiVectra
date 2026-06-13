#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macOS run bundle: SKIP"
  exit 0
fi

if [[ -z "${AILANG_BIN:-}" ]]; then
  if [[ -x "$ROOT_DIR/../AiLang/tools/ailang" ]]; then
    AILANG_BIN="$ROOT_DIR/../AiLang/tools/ailang"
  elif [[ -x "${HOME}/.ailang/current/bin/ailang" ]]; then
    AILANG_BIN="${HOME}/.ailang/current/bin/ailang"
  else
    echo "macOS run bundle: missing ailang executable" >&2
    exit 1
  fi
fi

fixture="$ROOT_DIR/test-fixtures/HelloWorld"
bundle="$(
  AILANG_DISABLE_RUN_TOOL_DISPATCH=1 \
  AIVECTRA_PREPARE_MACOS_BUNDLE_ONLY=1 \
  AIVECTRA_USE_MACOS_BUNDLE=1 \
    "$ROOT_DIR/scripts/aivectra" --ailang "$AILANG_BIN" run "$fixture/app.aibc1"
)"
launcher="$bundle/Contents/MacOS/HelloWorld"
plist="$bundle/Contents/Info.plist"

test -x "$launcher"
test ! -e "$bundle/Contents/MacOS/ailang-runtime"
cmp "$fixture/app.aibc1" "$bundle/Contents/MacOS/app.aibc1"
test -s "$bundle/Contents/Resources/AppIcon.icns"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$plist")" == "HelloWorld" ]]
file "$launcher" | grep -q 'Mach-O'
codesign --verify --deep --strict "$bundle"

echo "macOS run bundle: PASS"
