#!/usr/bin/env bash
# Start a contribution: branch community/<domain>/<slug> from upstream/main in a worktree under .claude/worktrees/<slug>.
# Usage: bcq-start.sh <domain> <slug>    -> prints the worktree path
set -euo pipefail
source "$(dirname "$0")/_lib.sh"
cd "$TOOLKIT_ROOT"; require_fork
domain="${1:-}"; slug="${2:-}"
[[ -z "$domain" || -z "$slug" ]] && { echo "usage: $0 <domain> <slug>" >&2; exit 2; }
[[ "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || { echo "ERROR: slug must be kebab-case" >&2; exit 2; }
[[ "$domain" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || { echo "ERROR: domain must be kebab-case" >&2; exit 2; }
branch="community/$domain/$slug"; wt="$WORKTREES/$slug"
[[ -e "$wt" ]] && { echo "worktree already exists: $wt"; exit 0; }
git fetch -q upstream
mkdir -p "$WORKTREES"
if git show-ref --verify --quiet "refs/heads/$branch"; then
  git worktree add -q "$wt" "$branch"
else
  git worktree add -q -b "$branch" "$wt" upstream/main
fi
echo "$wt"
