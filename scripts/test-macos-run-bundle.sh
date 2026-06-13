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
runtime="$bundle/Contents/MacOS/ailang-runtime"
plist="$bundle/Contents/Info.plist"

test -x "$launcher"
test -x "$runtime"
test -s "$bundle/Contents/Resources/AppIcon.icns"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$plist")" == "HelloWorld" ]]
file "$launcher" | grep -q 'Mach-O universal binary'
lipo "$launcher" -verify_arch arm64 x86_64
"$launcher" --version >/dev/null
"$launcher" -psn_0_12345 --version >/dev/null

mv "$runtime" "$runtime.real"
cat > "$runtime" <<'EOF'
#!/bin/sh
printf 'dispatch=%s\n' "${AILANG_DISABLE_RUN_TOOL_DISPATCH:-}"
printf 'args=%s\n' "$*"
EOF
chmod +x "$runtime"
launcher_output="$("$launcher" run app.aibc1 -psn_0_12345 -- live)"
grep -q '^dispatch=1$' <<<"$launcher_output"
grep -q '^args=run app.aibc1 -- live$' <<<"$launcher_output"
mv "$runtime.real" "$runtime"
codesign --verify --deep --strict "$bundle"

echo "macOS run bundle: PASS"
