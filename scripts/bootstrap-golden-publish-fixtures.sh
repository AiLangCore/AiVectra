#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$ROOT_DIR/.artifacts/debug"
mkdir -p "$ROOT_DIR/examples/debug/scenarios"
mkdir -p "$ROOT_DIR/examples/debug/events"

if [[ ! -f "$ROOT_DIR/examples/debug/scenarios/minimal.scenario.toml" ]]; then
  cat > "$ROOT_DIR/examples/debug/scenarios/minimal.scenario.toml" <<'TOML'
[[scenario]]
name = "minimal"
appPath = "examples/debug/apps/debug_minimal.aos"
vm = "bytecode"
debugMode = "live"
eventsPath = ""
comparePath = ""
outDir = ".artifacts/debug/minimal"
args = ""
TOML
fi

if [[ ! -f "$ROOT_DIR/examples/debug/events/minimal.events.toml" ]]; then
  cat > "$ROOT_DIR/examples/debug/events/minimal.events.toml" <<'TOML'
events = []
TOML
fi

echo "[bootstrap] fixtures ready"
echo "  scenario: $ROOT_DIR/examples/debug/scenarios/minimal.scenario.toml"
echo "  events:   $ROOT_DIR/examples/debug/events/minimal.events.toml"
