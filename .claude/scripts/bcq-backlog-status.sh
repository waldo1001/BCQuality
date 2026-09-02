#!/usr/bin/env bash
# Is the scout backlog for the company guidelines still fresh?
# Compares the upstream SHA and the source-folder fingerprint recorded in the backlog with the current state.
# Usage: bcq-backlog-status.sh [source-dir]     Exit 0 = fresh, 3 = stale or missing (re-scout).
set -euo pipefail
source "$(dirname "$0")/_lib.sh"; cd "$TOOLKIT_ROOT"
src="${1:-/Users/waldo/SourceCode/iFacto/iFactoAcademy/iFacto Playbook/BCQuality/custom/knowledge}"
backlog=$(ls -t .claude/scout/*-ifacto-custom-layer.md 2>/dev/null | head -1 || true)
[[ -z "$backlog" ]] && { echo "STALE: no backlog yet; run /bcq-scout"; exit 3; }

git fetch -q upstream 2>/dev/null || true
up_now=$(git rev-parse --short upstream/main)
up_then=$(grep -oE 'upstream `main` [0-9a-f]{7,}' "$backlog" | grep -oE '[0-9a-f]{7,}$' || echo "?")
fp_now=$(cd "$src" && find . -name '*.md' -print0 | sort -z | xargs -0 shasum | shasum | cut -c1-12)
fp_then=$(grep -oE 'Source fingerprint: [0-9a-f]{12}' "$backlog" | grep -oE '[0-9a-f]{12}$' || echo "?")

echo "backlog:  $backlog"
echo "upstream: recorded $up_then, now $up_now"
echo "source:   recorded $fp_then, now $fp_now"
stale=false
[[ "$up_then" != "$up_now" ]] && stale=true
[[ "$fp_then" != "$fp_now" ]] && stale=true
if $stale; then
  echo "STALE: re-scout (new upstream articles or changed company guidelines can change verdicts)."
  echo "Company articles not mentioned in the backlog:"
  (cd "$src" && find . -name '*.md' | sed 's|^\./||; s|\.md$||') | while read -r a; do grep -q -- "$a" "$backlog" || echo "  + $a"; done
  exit 3
fi
echo "FRESH: reuse the backlog."
