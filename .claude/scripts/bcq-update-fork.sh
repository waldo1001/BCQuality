#!/usr/bin/env bash
# Update the fork: merge microsoft/BCQuality main into the fork's main (keeping the toolkit commit on top),
# push it, and report or rebase the open contribution worktrees.
# Usage: bcq-update-fork.sh [--rebase]
set -euo pipefail
source "$(dirname "$0")/_lib.sh"
cd "$TOOLKIT_ROOT"; require_fork
rebase=false; [[ "${1:-}" == "--rebase" ]] && rebase=true

[[ "$(git branch --show-current)" == "main" ]] || { echo "ERROR: the main checkout must be on main (it is on $(git branch --show-current))" >&2; exit 1; }
if [[ -n "$(git status --porcelain)" ]]; then echo "ERROR: main checkout has uncommitted changes; commit the toolkit first" >&2; git status --short; exit 1; fi

git fetch --prune upstream
git fetch --prune origin
before=$(git rev-parse --short HEAD)
git merge --no-edit upstream/main
git push origin main:main
echo
echo "main: $before -> $(git rev-parse --short HEAD); upstream/main: $(git rev-parse --short upstream/main); toolkit commits on top: $(git rev-list --count upstream/main..main)"

echo
echo "Contribution worktrees vs upstream/main:"
git worktree list --porcelain | awk '/^worktree /{print $2}' | while read -r wt; do
  [[ "$wt" == "$TOOLKIT_ROOT" ]] && continue
  b=$(git -C "$wt" branch --show-current)
  ahead=$(git -C "$wt" rev-list --count "upstream/main..$b"); behind=$(git -C "$wt" rev-list --count "$b..upstream/main")
  if (( behind > 0 )) && $rebase; then
    if [[ -n "$(git -C "$wt" status --porcelain)" ]]; then echo "  $b: behind $behind, dirty, skipped rebase"; continue; fi
    git -C "$wt" rebase -q upstream/main && echo "  $b: rebased onto upstream/main (ahead $ahead)"
  else
    flag=""; (( behind > 0 )) && flag="  <- rebase before PR (bcq-update-fork.sh --rebase)"
    echo "  $b: ahead $ahead, behind $behind$flag"
  fi
done
