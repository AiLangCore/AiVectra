#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

supports_packages() {
  local bin="$1"
  "$bin" --help 2>&1 | grep -q 'package <'
}

if [[ -n "${AILANG_BIN:-}" ]] && supports_packages "$AILANG_BIN"; then
  :
elif [[ -x "$ROOT_DIR/.tools/ailang" ]] && supports_packages "$ROOT_DIR/.tools/ailang"; then
  AILANG_BIN="$ROOT_DIR/.tools/ailang"
elif [[ -x "$ROOT_DIR/../AiLang/tools/ailang" ]] && supports_packages "$ROOT_DIR/../AiLang/tools/ailang"; then
  AILANG_BIN="$ROOT_DIR/../AiLang/tools/ailang"
elif [[ -x "${HOME}/.ailang/bin/ailang" ]] && supports_packages "${HOME}/.ailang/bin/ailang"; then
  AILANG_BIN="${HOME}/.ailang/bin/ailang"
elif command -v ailang >/dev/null 2>&1 && supports_packages "$(command -v ailang)"; then
  AILANG_BIN="$(command -v ailang)"
else
  echo "package surface test requires an ailang binary with package command support" >&2
  exit 2
fi

TMP_DIR="$ROOT_DIR/.tmp/package-surface"
REGISTRY_DIR="$TMP_DIR/registry"
APP_DIR="$TMP_DIR/app"
COMMIT="$(git -C "$ROOT_DIR" rev-parse HEAD)"
STD_APP_COMMIT="$(git -C "$ROOT_DIR/../ailang-core-packages" rev-parse HEAD)"

rm -rf "$TMP_DIR"
mkdir -p "$REGISTRY_DIR/packages"

cat > "$REGISTRY_DIR/packages/aivectra.toml" <<EOF
schema = "ailang.package.v1"
name = "aivectra"
repo = "$ROOT_DIR"
packageRoot = "."
license = "MIT"
types = ["library", "tool", "template"]
defaultVersion = "0.0.1-test"

[versions."0.0.1-test"]
ref = "HEAD"
commit = "$COMMIT"
EOF

cat > "$REGISTRY_DIR/packages/std-app.toml" <<EOF
schema = "ailang.package.v1"
name = "std-app"
repo = "$ROOT_DIR/../ailang-core-packages"
packageRoot = "packages/std-app"
license = "MIT"
types = ["library"]
defaultVersion = "0.0.1-alpha.2"

[versions."0.0.1-alpha.2"]
ref = "HEAD"
commit = "$STD_APP_COMMIT"
EOF

"$AILANG_BIN" init "$APP_DIR" >/dev/null
AILANG_PACKAGE_REGISTRY="$REGISTRY_DIR" "$AILANG_BIN" package add aivectra "$APP_DIR" >/dev/null

"$AILANG_BIN" package list "$APP_DIR" | grep -q 'aivectra 0.0.1-test'
"$AILANG_BIN" package list "$APP_DIR" | grep -q 'std-app 0.0.1-alpha.2'
"$AILANG_BIN" template list projects "$APP_DIR" | grep -q 'aivectra/hello-name'
"$AILANG_BIN" template list files "$APP_DIR" | grep -q 'aivectra/view-basic'

(
  cd "$APP_DIR"
  AILANG_BIN="$AILANG_BIN" "$AILANG_BIN" aivectra --help | grep -q 'AiVectra AiLang wrapper'
)

echo "package surface checks passed"
