#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
fixtures_dir="$ROOT_DIR/test-fixtures"

failed=0

while IFS= read -r stale_src; do
  echo "fixture structure error: use lowercase src/ instead of Src/: ${stale_src#$ROOT_DIR/}"
  failed=1
done < <(find "$fixtures_dir" -type d -name Src | sort)

while IFS= read -r metadata_file; do
  echo "fixture structure error: remove OS metadata file: ${metadata_file#$ROOT_DIR/}"
  failed=1
done < <(find "$fixtures_dir" -name .DS_Store -print | sort)

while IFS= read -r project_file; do
  entry_file="$(sed -n 's/.*entryFile="\([^"]*\)".*/\1/p' "$project_file" | head -n 1)"
  if [[ -z "$entry_file" ]]; then
    echo "fixture structure error: missing entryFile in ${project_file#$ROOT_DIR/}"
    failed=1
    continue
  fi

  if [[ "$entry_file" != src/* ]]; then
    echo "fixture structure error: entryFile must live under src/: ${project_file#$ROOT_DIR/} -> $entry_file"
    failed=1
  fi

  project_dir="$(dirname "$project_file")"
  if [[ ! -f "$project_dir/$entry_file" ]]; then
    echo "fixture structure error: entryFile does not exist: ${project_file#$ROOT_DIR/} -> $entry_file"
    failed=1
  fi
done < <(find "$fixtures_dir" -name project.aiproj -print | sort)

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

echo "fixture structure checks passed"
