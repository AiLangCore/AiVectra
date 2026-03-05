#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AIVECTRA="$ROOT_DIR/scripts/aivectra"
AIRUN_BIN="${AIRUN_BIN:-$ROOT_DIR/.tools/airun}"
HELP_TEXT="$("$AIRUN_BIN" --help 2>&1 || true)"
REQUIRES_PREBUILT=0
if [[ "$HELP_TEXT" != *".aos"* || "$HELP_TEXT" != *"project-dir"* ]]; then
  REQUIRES_PREBUILT=1
fi

tmp_dir="$ROOT_DIR/.artifacts/debug/cli-contract"
mkdir -p "$tmp_dir"

if [[ $REQUIRES_PREBUILT -eq 1 && ! -f "$ROOT_DIR/samples/HelloName/app.aibc1" ]]; then
  echo "[cli-contract] native-c guard (explicit target)"
  set +e
  out_guard="$("$AIVECTRA" debug --debug-mode live "$ROOT_DIR/samples/HelloName/" 2>&1)"
  rc_guard=$?
  set -e
  if [[ $rc_guard -ne 2 ]]; then
    echo "expected exit 2 for native-c guard, got $rc_guard" >&2
    exit 1
  fi
  printf "%s\n" "$out_guard" | rg -q 'code=AIV001' || {
    echo "expected AIV001 native-c guard message" >&2
    exit 1
  }
else
  echo "[cli-contract] explicit target + forwarding boundary"
  "$AIVECTRA" debug --debug-mode live "$ROOT_DIR/samples/HelloName/" -- --debug-mode=bogus >/dev/null
fi

if [[ $REQUIRES_PREBUILT -eq 1 && ! -f "$ROOT_DIR/samples/HelloWorld/app.aibc1" ]]; then
  echo "[cli-contract] native-c guard (implicit cwd project)"
  set +e
  out_cwd="$(
    cd "$ROOT_DIR/samples/HelloWorld" && \
    ../../scripts/aivectra debug --debug-mode snapshot --out ../../.artifacts/debug/cli-contract-cwd 2>&1
  )"
  rc_cwd=$?
  set -e
  if [[ $rc_cwd -ne 2 ]]; then
    echo "expected exit 2 for native-c cwd guard, got $rc_cwd" >&2
    exit 1
  fi
  printf "%s\n" "$out_cwd" | rg -q 'code=AIV001' || {
    echo "expected AIV001 for native-c cwd guard" >&2
    exit 1
  }
else
  echo "[cli-contract] implicit cwd project inference"
  (
    cd "$ROOT_DIR/samples/HelloName"
    ../../scripts/aivectra debug --debug-mode snapshot --out ../../.artifacts/debug/cli-contract-cwd >/dev/null
  )
fi

echo "[cli-contract] invalid source propagates RUN002 + exit 2"
set +e
out_missing="$("$AIVECTRA" run "$ROOT_DIR/samples/Nope/" 2>&1)"
rc_missing=$?
set -e
if [[ $rc_missing -ne 2 ]]; then
  echo "expected exit 2 for missing source, got $rc_missing" >&2
  exit 1
fi
if [[ $REQUIRES_PREBUILT -eq 1 ]]; then
  printf "%s\n" "$out_missing" | rg -q 'code=AIV001|code=RUN001|code=RUN002' || {
    echo "expected AIV001/RUN001/RUN002 for missing source when prebuilt bytecode is required" >&2
    exit 1
  }
else
  printf "%s\n" "$out_missing" | rg -q 'code=RUN001|code=RUN002' || {
    echo "expected RUN001 or RUN002 for missing source" >&2
    exit 1
  }
fi

echo "[cli-contract] unknown debug option returns exit 2"
set +e
out_opt="$("$AIVECTRA" debug --badopt "$ROOT_DIR/samples/HelloWorld/" 2>&1)"
rc_opt=$?
set -e
if [[ $rc_opt -ne 2 ]]; then
  echo "expected exit 2 for unknown debug option, got $rc_opt" >&2
  exit 1
fi
printf "%s\n" "$out_opt" | rg -q 'unknown debug option:' || {
  echo "expected unknown debug option message" >&2
  exit 1
}

echo "cli contract checks passed"
