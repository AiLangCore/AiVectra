#!/usr/bin/env zsh
set -euo pipefail

root="${1:-.}"
exit_code=0

while IFS= read -r file; do
  dups=$(perl -ne '
    while (/\b[A-Za-z][A-Za-z0-9_]*#([A-Za-z0-9_]+)/g) { $c{$1}++ }
    END { for $k (sort keys %c) { print "$k\n" if $c{$k} > 1 } }
  ' "$file")
  if [[ -n "$dups" ]]; then
    exit_code=1
    echo "Duplicate node IDs in $file"
    echo "$dups"
  fi
done < <(find "$root" -path "$root/.tools" -prune -o \( -name '*.aos' -o -name '*.aiproj' \) -type f -print)

if [[ "$exit_code" -eq 0 ]]; then
  echo "No duplicate node IDs found."
fi

exit "$exit_code"
