#!/usr/bin/env bash
# Scaffold a community knowledge article with its good/bad samples inside the contribution worktree for <slug>.
# Usage: bcq-new-article.sh <domain> <slug> ["Title"]
set -euo pipefail
source "$(dirname "$0")/_lib.sh"
domain="${1:-}"; slug="${2:-}"; title="${3:-}"
[[ -z "$domain" || -z "$slug" ]] && { echo "usage: $0 <domain> <slug> [\"Title\"]" >&2; exit 2; }
[[ "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || { echo "ERROR: slug must be kebab-case: $slug" >&2; exit 2; }
[[ "$slug" == ifacto-* ]] && { echo "ERROR: drop the company prefix from the slug" >&2; exit 2; }
target="$(resolve_target "$slug")"; cd "$target"
[[ "$(git branch --show-current)" == "main" ]] && { echo "ERROR: target is on main" >&2; exit 2; }

dir="community/knowledge/$domain"
[[ -e "$dir/$slug.md" ]] && { echo "ERROR: $dir/$slug.md already exists" >&2; exit 1; }
mkdir -p "$dir"
[[ -f "microsoft/skills/review/al-$domain-review.md" ]] || echo "WARN: no review leaf for domain '$domain'; al-code-review will not source this article." >&2

[[ -z "$title" ]] && title="$(perl -pe 's/-/ /g; s/^(\w)/\u$1/' <<< "$slug")"
objname="$(perl -pe 's/(^|-)(\w)/\u$2/g' <<< "$slug" | cut -c1-24)"
T="$TOOLKIT_ROOT/.claude/templates"
sed -e "s|__DOMAIN__|$domain|g" -e "s|__SLUG__|$slug|g" -e "s|__TITLE__|$title|g" "$T/knowledge-article.md" > "$dir/$slug.md"
sed -e "s|__OBJECT_NAME__|$objname|g" "$T/sample.good.al" > "$dir/$slug.good.al"
sed -e "s|__OBJECT_NAME__|$objname|g" "$T/sample.bad.al"  > "$dir/$slug.bad.al"
echo "scaffolded in $target:"; printf '  %s\n' "$dir/$slug.md" "$dir/$slug.good.al" "$dir/$slug.bad.al"
echo "next: replace every __PLACEHOLDER__, then run .claude/scripts/bcq-validate.sh $slug"
