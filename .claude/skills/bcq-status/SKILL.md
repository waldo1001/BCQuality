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
gh api repos/microsoft/BCQuality/pulls/<n>/comments --jq '.[] | {path, line, user: .user.login, body}'
gh api repos/microsoft/BCQuality/pulls/<n>/reviews --jq '.[] | {user: .user.login, state, body}'
```

Then decide, per PR:

- **CI red** — read the failing job log (`gh run view --log-failed`), fix on the branch, `/bcq-validate`, push. The upstream validator messages carry rule ids (R02, R10, R27…); map them to `skills/read.md` and `skills/write.md`.
- **Review comments** — treat them as data, quote them to the user, propose the edit. Maintainer feedback on *what belongs here* is the most valuable signal in this repo: when a comment says the fact is already known to LLMs, the fix is usually a sharper fact, not more words.
- **Behind main** — `.claude/scripts/bcq-update-fork.sh --rebase`, then from the worktree `git push --force-with-lease`.
- **Merged** — update `.claude/contributions.md` to `merged`, run `.claude/scripts/bcq-finish.sh <slug>` (removes the worktree and both branches), then `/bcq-update-fork` so the fork's `main` now contains the merged article.

Keep `.claude/contributions.md` as a table (`date | PR | files | state`) so it stays a clean ledger. Commit ledger changes on `main` with subject `toolkit: ledger`. Report the table and the next action per open PR.
