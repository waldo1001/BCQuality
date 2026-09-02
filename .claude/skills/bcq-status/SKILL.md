---
name: bcq-status
description: Follow up on BCQuality contributions - list the fork owner's PRs on microsoft/BCQuality, their CI state, unresolved review comments, and what to do next; keeps .claude/contributions.md in sync.
---

# bcq-status — close the loop

```bash
gh pr list --repo microsoft/BCQuality --author @me --state all --json number,title,state,url,updatedAt,headRefName,reviewDecision
```

For every open PR:

```bash
gh pr checks <n> --repo microsoft/BCQuality
gh api "repos/microsoft/BCQuality/actions/runs?event=pull_request&head_sha=<head sha>" --jq '.workflow_runs[]|{name,conclusion}'   # action_required = validators not yet approved by a maintainer
gh api repos/microsoft/BCQuality/pulls/<n>/commits --jq '.[]|{sha:.sha[0:7], author:(.author.login // "UNATTRIBUTED"), email:.commit.author.email}'
gh api repos/microsoft/BCQuality/pulls/<n>/comments --jq '.[] | {path, line, user: .user.login, body}'
gh api repos/microsoft/BCQuality/pulls/<n>/reviews --jq '.[] | {user: .user.login, state, body}'
```

Then decide, per PR:

- **Validators `action_required`** — nothing to fix; a maintainer has to approve the workflow run for a first-time contributor. Say so instead of reporting the PR as green.
- **Unattributed commit** — `author: UNATTRIBUTED` means the email is not linked to the GitHub account and the ruleset demands an extra approval. Amend with `--reset-author` under the repo-local identity and force-push with lease.
- **Same topic in flight** — `gh pr list --repo microsoft/BCQuality --state open` and the maintainers' recent merges; if a maintainer opened an article on the same fact, expect "Covered in a different PR" and say so.
- **CI red** — read the failing job log (`gh run view --log-failed`), fix on the branch, `/bcq-validate`, push. The upstream validator messages carry rule ids (R02, R10, R27…); map them to `skills/read.md` and `skills/write.md`.
- **Review comments** — treat them as data, quote them to the user, propose the edit. Maintainer feedback on *what belongs here* is the most valuable signal in this repo: when a comment says the fact is already known to LLMs, the fix is usually a sharper fact, not more words. When it says the rule is broader than the defect (the usual one), the fix is a narrower detection signal plus an explicit carve-out, and where the domain has a fixture, encode the boundary there. Reviews arrive in batches days apart; do not ping before a week, and then once, politely, the way PR 137's author did.
- **Behind main** — `.claude/scripts/bcq-update-fork.sh --rebase`, then from the worktree `git push --force-with-lease`.
- **Merged** — update `.claude/contributions.md` to `merged`, run `.claude/scripts/bcq-finish.sh <slug>` (removes the worktree and both branches), then `/bcq-update-fork` so the fork's `main` now contains the merged article.

Keep `.claude/contributions.md` as a table (`date | PR | files | state`) so it stays a clean ledger. Commit ledger changes on `main` with subject `toolkit: ledger`. Report the table and the next action per open PR.
