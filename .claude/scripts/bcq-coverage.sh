#!/usr/bin/env bash
# Overlap check: which existing articles (microsoft + community, on the fork's main) already mention these terms?
# Usage: bcq-coverage.sh <term> [<term> ...]
set -euo pipefail
source "$(dirname "$0")/_lib.sh"; cd "$TOOLKIT_ROOT"
[[ $# -eq 0 ]] && { echo "usage: $0 <term> [<term> ...]" >&2; exit 2; }
for term in "$@"; do
  echo "== '$term'"
  hits=$(grep -ril -- "$term" microsoft/knowledge community/knowledge 2>/dev/null | sed -E 's/\.(good|bad)\.[a-z0-9]+$/.md/' | sort -u || true)
  [[ -z "$hits" ]] && { echo "   (no existing article mentions this)"; continue; }
  while IFS= read -r f; do [[ -f "$f" ]] || continue; echo "   $f"; echo "      $(grep -m1 '^# ' "$f" | sed 's/^# //')"; done <<< "$hits"
done
