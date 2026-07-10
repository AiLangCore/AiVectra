#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail=0

error() {
  printf 'doc-taxonomy: %s\n' "$1" >&2
  fail=1
}

# Local scratch files must remain untracked. This catches files committed by
# bypassing the repository ignore rules.
while IFS= read -r path; do
  case "$path" in
    *.local.md|*.local.*)
      error "local scratch file is tracked: $path"
      ;;
  esac
done < <(git ls-files)

# SPEC contains normative contracts and explicit cross-repository pointers only.
while IFS= read -r path; do
  base="${path##*/}"
  case "$base" in
    *.feature-*.md|*.rc[0-9]*.md|*.milestone-*.md|*.note.md|*.experiment.md|*.archive.md)
      error "non-normative lifecycle file under SPEC: $path"
      ;;
  esac

  if grep -Eiq 'Status: (non-normative|active .*checklist|completed execution plan)|^# Task:|^# .*Checklist$|^# .*Readiness$|^## Backlog$' "$path"; then
    case "$base" in
      README.md) ;;
      *) error "SPEC file contains planning/design lifecycle wording: $path" ;;
    esac
  fi
done < <(git ls-files 'SPEC/*.md')

# Docs contains stable usage documentation, not active planning or proposals.
while IFS= read -r path; do
  base="${path##*/}"
  case "$base" in
    *.feature-*.md|*.rc[0-9]*.md|*.milestone-*.md|*.experiment.md|*.archive.md)
      error "lifecycle planning/design file under Docs: $path"
      ;;
  esac

  if grep -Eiq 'Status: active .*checklist|completed execution plan|^# Task:|^# .*Tasks$|^# .*Checklist$|^# .*Readiness$' "$path"; then
    error "active planning/checklist content under Docs: $path"
  fi
done < <(git ls-files 'Docs/*.md')

# Design files must clearly identify their non-normative/design role.
while IFS= read -r path; do
  base="${path##*/}"
  [ "$base" = "README.md" ] && continue
  if ! grep -Eiq 'non-normative|decision|proposal|design|experiment' "$path"; then
    error "design file lacks non-normative/design status wording: $path"
  fi
done < <(git ls-files 'Design/*.md')

# Planning files must expose planning/gate context.
while IFS= read -r path; do
  base="${path##*/}"
  [ "$base" = "README.md" ] && continue
  if ! grep -Eiq 'Status:|Scope|Gate|Milestone|Readiness|Exit|Objective|Goal|Checklist' "$path"; then
    error "planning file lacks status/scope/gate wording: $path"
  fi
done < <(git ls-files 'Planning/*.md')

exit "$fail"
