# Shared helpers for the bcq-* scripts. Source, do not execute.
TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKTREES="$TOOLKIT_ROOT/.claude/worktrees"

# Portable timeout (macOS ships no coreutils `timeout`); stdin from /dev/null because pwsh blocks on an open non-tty stdin.
with_timeout() { local secs=$1; shift; perl -e 'alarm shift; exec @ARGV' "$secs" "$@" < /dev/null; }

# resolve_target [slug] -> prints the contribution worktree path.
# With a slug: .claude/worktrees/<slug>. Without: the current checkout, which must not be the main checkout.
resolve_target() {
  local slug="${1:-}"
  if [[ -n "$slug" ]]; then
    [[ -d "$WORKTREES/$slug" ]] || { echo "ERROR: no worktree for '$slug' (run bcq-start.sh <domain> $slug)" >&2; return 2; }
    echo "$WORKTREES/$slug"; return 0
  fi
  local top; top="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -z "$top" || "$top" == "$TOOLKIT_ROOT" ]]; then
    echo "ERROR: run inside a contribution worktree or pass <slug>. Worktrees:" >&2
    ls "$WORKTREES" 2>/dev/null | sed 's/^/  /' >&2
    return 2
  fi
  echo "$top"
}

require_fork() {
  local origin; origin=$(git -C "$TOOLKIT_ROOT" remote get-url origin)
  [[ "$origin" == *"github.com/microsoft/BCQuality"* ]] && { echo "ERROR: origin is upstream microsoft/BCQuality; work in a fork" >&2; return 1; }
  git -C "$TOOLKIT_ROOT" remote get-url upstream >/dev/null 2>&1 || git -C "$TOOLKIT_ROOT" remote add upstream https://github.com/microsoft/BCQuality.git
}
