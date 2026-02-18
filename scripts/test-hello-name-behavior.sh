#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"

out_replay="$("$AIVECTRA" run "$ROOT_DIR/samples/HelloName/" replay)"

echo "$out_replay" | rg -q "\\[aivectra\\] replay greeting=Greeting: Hello, todd!" || {
  echo "missing replay greeting output" >&2
  exit 1
}

echo "$out_replay" | rg -q "\\[aivectra\\] replay backspace=ted" || {
  echo "missing replay backspace output" >&2
  exit 1
}

echo "$out_replay" | rg -q "type=\"click\"" || {
  echo "missing replay click output" >&2
  exit 1
}

out_snapshot="$("$AIVECTRA" run "$ROOT_DIR/samples/HelloName/" snapshot)"
echo "$out_snapshot" | rg -q "\\[aivectra\\] snapshot size=976x614" || {
  echo "missing snapshot size output" >&2
  exit 1
}

echo "$out_snapshot" | rg -q "button=418,454,140,52" || {
  echo "missing expected button layout signature" >&2
  exit 1
}

echo "hello-name behavior checks passed"
