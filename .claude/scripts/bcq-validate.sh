#!/usr/bin/env bash
# Run the upstream CI checks locally inside a contribution worktree, plus the guards the upstream bots enforce.
# Usage: bcq-validate.sh [slug]      Exit 0 = ready for PR (warnings allowed). Exit 1 = fix first.
set -uo pipefail
source "$(dirname "$0")/_lib.sh"
target="$(resolve_target "${1:-}")" || exit 2
cd "$target"
errors=0; warnings=0
err()  { echo "  ✗ $*"; errors=$((errors+1)); }
warn() { echo "  ! $*"; warnings=$((warnings+1)); }
ok()   { echo "  ✓ $*"; }

echo "== 0. Target: $target"
echo "== 1. Branch and remotes"
branch=$(git branch --show-current)
[[ "$branch" == "main" || -z "$branch" ]] && err "target is on '$branch'; contributions live on community/<domain>/<slug>" || ok "branch: $branch"
require_fork && ok "origin is the fork; upstream remote present" || err "remote setup"
git fetch -q upstream 2>/dev/null || warn "could not fetch upstream (offline?)"
behind=$(git rev-list --count "HEAD..upstream/main" 2>/dev/null || echo "?")
[[ "$behind" == "0" ]] && ok "up to date with upstream/main" || warn "branch is $behind commit(s) behind upstream/main; rebase before PR (bcq-update-fork.sh --rebase)"
email=$(git log -1 --format=%ae 2>/dev/null)
if [[ "$email" == *"@users.noreply.github.com" ]]; then ok "commit author $email is a GitHub-linked identity"
else warn "commit author $email must be linked to the GitHub account, or the upstream ruleset asks for an extra approval (git commit --amend --reset-author under a linked identity)"; fi

echo "== 2. Change scope (vs upstream/main, committed, uncommitted, and untracked)"
changed=$( { git diff --name-only upstream/main 2>/dev/null; git ls-files --others --exclude-standard; } | sort -u )
[[ -z "$changed" ]] && err "no changes relative to upstream/main"
while IFS= read -r p; do
  [[ -z "$p" ]] && continue
  case "$p" in
    community/*) ;;
    custom/*) err "$p — custom/ content is auto-closed upstream (Guard custom layer)";;
    microsoft/*|skills/*|.github/*|tools/*|evaluation/*) warn "$p — outside community/; needs maintainer review, keep it in a separate PR";;
    */*) err "$p — unexpected top-level folder '${p%%/*}' (flagged by Flag new top-level entries)";;
    *) err "$p — new top-level file (flagged by Flag new top-level entries)";;
  esac
done <<< "$changed"
[[ $errors -eq 0 ]] && ok "all changes inside community/"

echo "== 3. Upstream validator (validate_frontmatter.py)"
if out=$(python3 .github/scripts/validate_frontmatter.py --root . 2>&1); then ok "$(echo "$out" | tail -1)"; else echo "$out" | sed 's/^/    /'; err "validator failed"; fi

echo "== 4. Knowledge index generator (Test-KnowledgeIndex.ps1)"
if out=$(with_timeout 300 pwsh -NoProfile -NonInteractive -File .github/scripts/Test-KnowledgeIndex.ps1 -Root . 2>&1); then ok "$(echo "$out" | tail -1)"; else rc=$?; echo "$out" | tail -5 | sed 's/^/    /'; (( rc == 142 )) && err "index check timed out after 300s" || err "index check failed"; fi

echo "== 5. Review fixtures (Test-ReviewFixtures.ps1)"
if out=$(with_timeout 300 pwsh -NoProfile -NonInteractive -File tools/Test-ReviewFixtures.ps1 -Root . 2>&1); then ok "$(echo "$out" | tail -1)"; else rc=$?; echo "$out" | tail -5 | sed 's/^/    /'; (( rc == 142 )) && err "fixtures check timed out after 300s" || err "fixtures check failed"; fi

echo "== 6. Per-article contributor checks"
articles=$(echo "$changed" | grep -E '^community/knowledge/[^/]+/[^/]+\.md$' || true)
[[ -z "$articles" ]] && echo "  (no community articles changed)"
while IFS= read -r a; do
  [[ -z "$a" || ! -f "$a" ]] && continue
  dir=$(dirname "$a"); slug=$(basename "$a" .md); domain=$(basename "$dir")
  echo "  -- $a"
  lines=$(wc -l < "$a" | tr -d ' '); (( lines > 100 )) && err "$lines lines (max 100)" || ok "$lines lines"
  grep -q '^# ' "$a" && ok "H1 title present" || err "missing H1 title"
  grep -q 'Contributions welcome' "$a" && ok "community tagline present" || warn "missing community tagline '> Contributions welcome — open a PR to refine or extend this article.'"
  grep -q '__[A-Z_]*__' "$a" && err "template placeholder left in article"
  grep -qiE 'ifacto|distri|company standard|company rule|mandatory at ' "$a" && err "company-specific wording found; make it a BC fact"
  for kind in good bad; do
    s="$dir/$slug.$kind.al"
    if [[ -f "$s" ]]; then
      grep -q "$slug.$kind.al" "$a" && ok "$kind sample present and referenced" || err "$kind sample exists but is not referenced from the article"
      grep -q '__[A-Z_]*__' "$s" && err "template placeholder left in $slug.$kind.al"
      head -3 "$s" | grep -qiE "\"[^\"]*\b(Good|Bad)\"" || warn "$slug.$kind.al: first object name does not end in Good/Bad (evaluation harness neutralises those tokens)"
      grep -qiE 'ifacto|distri' "$s" && err "company name inside $slug.$kind.al"
    else warn "no $kind sample ($slug.$kind.al)"; fi
  done
  [[ -f "microsoft/skills/review/al-$domain-review.md" ]] && ok "domain '$domain' has a review leaf" || warn "domain '$domain' has no review leaf; al-code-review will not source it"
  kw=$(grep -m1 '^keywords:' "$a" | tr ',' '\n' | wc -l | tr -d ' '); (( kw > 10 )) && warn "$kw keywords (aim for 3-10)"
  musts=$(grep -oiE '\bmust\b' "$a" | wc -l | tr -d ' '); (( musts > 2 )) && warn "$musts occurrences of 'must'; the reviewer downgrades any not mandated by the docs"
  grep -qiE 'detection( signal)?:' "$a" && ok "Anti Pattern carries a detection signal" || warn "no 'Detection signal:' sentence in the Anti Pattern"
  grep -qiE 'do not flag|not a defect|is not sufficient evidence|legitimate|valid exception|never flag' "$a" && ok "carve-out for the legitimate case present" || warn "no explicit carve-out (the shape that must not be flagged); 'rule broader than the defect' is the usual change request"
  grep -q '^## See also' "$a" && ok "See also with sources present" || warn "no '## See also' with the Learn URLs behind the claims"
  mybranch=$(git branch --show-current); inflight=""
  for kw in $(grep -m1 '^keywords:' "$a" | sed 's/^keywords:[[:space:]]*\[//; s/\].*//' | tr ',' '\n' | tr -d ' ' | grep -vE '^(false-positive)$' | head -3); do
    hits=$(gh pr list --repo microsoft/BCQuality --state open --search "$kw in:title" --json number,title,headRefName --jq ".[] | select(.headRefName != \"$mybranch\") | \"#\\(.number) \\(.title)\"" 2>/dev/null || true)
    [[ -n "$hits" ]] && inflight="$inflight$(printf '\n    %s (matched: %s)' "$hits" "$kw")"
  done
  [[ -n "$inflight" ]] && warn "open upstream PR(s) share a keyword; confirm none states the same fact and record an in-flight: line:$inflight" || ok "no open upstream PR matches the top keywords"
done <<< "$articles"

echo "== 6b. Overlap with existing articles (Gate B, must be addressed)"
while IFS= read -r a; do
  [[ -z "$a" || ! -f "$a" ]] && continue
  slug=$(basename "$a" .md); record="$TOOLKIT_ROOT/.claude/validation/$slug.md"
  neighbours=$("$TOOLKIT_ROOT/.claude/scripts/bcq-overlap.sh" "$a" 2>/dev/null || true)
  [[ -z "$neighbours" ]] && { ok "$slug: no keyword neighbours in the corpus"; continue; }
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    n=$(cut -d' ' -f1 <<< "$line"); path=$(cut -d' ' -f2 <<< "$line")
    verdict=""; [[ -f "$record" ]] && verdict=$(grep -E "^overlap:.*$(printf '%s' "$path" | sed 's/[.[\*^$/]/\\&/g')" "$record" | grep -oiE '\b(covered|delta|unrelated)\b' | head -1 | tr 'A-Z' 'a-z')
    case "$verdict" in
      covered)   err "$slug is COVERED by $path (recorded verdict); do not contribute" ;;
      delta|unrelated) ok "$path: $verdict (shares $n keyword(s), recorded in .claude/validation/$slug.md)" ;;
      *) if grep -q "$(basename "$path")" "$a"; then warn "$path: cited from the article but no verdict in .claude/validation/$slug.md (add 'overlap: $path — delta|covered — reason')"
         else err "$path shares $n keyword(s) and is neither cited nor given a verdict in .claude/validation/$slug.md"; fi ;;
    esac
  done <<< "$neighbours"
done <<< "$articles"

echo "== 7. Sample orphans in touched domains"
for d in $(echo "$changed" | grep -oE '^community/knowledge/[^/]+' | sort -u); do
  for s in "$d"/*.al; do [[ -f "$s" ]] || continue; base=$(basename "$s"); slug="${base%%.*}"; [[ -f "$d/$slug.md" ]] || err "orphan sample $s (no $slug.md)"; done
done

echo; echo "Result: $errors error(s), $warnings warning(s)"
[[ $errors -eq 0 ]] && exit 0 || exit 1
