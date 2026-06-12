#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT_DIR/native/apple-macos/launcher.c"
OUTPUT="$ROOT_DIR/Assets/launchers/apple-macos/aivectra-launcher"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macOS launcher build requires macOS" >&2
  exit 1
fi
if ! command -v clang >/dev/null 2>&1; then
  echo "macOS launcher build requires clang" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
clang -Os -arch arm64 -arch x86_64 "$SOURCE" -o "$OUTPUT"
chmod +x "$OUTPUT"
lipo "$OUTPUT" -verify_arch arm64 x86_64

echo "$OUTPUT"
