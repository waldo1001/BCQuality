#!/usr/bin/env bash
# Finish a contribution after its PR merged: remove the worktree and the local branch (fully-merged check).
# Usage: bcq-finish.sh <slug> [--force]
set -euo pipefail
source "$(dirname "$0")/_lib.sh"
cd "$TOOLKIT_ROOT"
slug="${1:?usage: $0 <slug> [--force]}"; force="${2:-}"
wt="$WORKTREES/$slug"; [[ -d "$wt" ]] || { echo "no worktree for $slug" >&2; exit 2; }
branch=$(git -C "$wt" branch --show-current)
git fetch -q upstream
git worktree remove ${force:+--force} "$wt"
if [[ "$force" == "--force" ]]; then git branch -D "$branch"; else git branch -d "$branch"; fi
git push origin --delete "$branch" 2>/dev/null && echo "deleted origin/$branch" || echo "(no remote branch to delete)"
echo "finished $slug"
