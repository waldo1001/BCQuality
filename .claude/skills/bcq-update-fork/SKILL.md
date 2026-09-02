---
name: bcq-update-fork
description: Update the BCQuality fork from microsoft/BCQuality - merge upstream main into the fork's main (keeping the toolkit commit on top), push the fork, and rebase or report the open contribution worktrees. Use before starting a contribution, before opening or updating a PR, and after a PR merges.
argument-hint: "[--rebase]"
---

# bcq-update-fork — keep the fork current

The fork's `main` is `upstream/main` plus the toolkit commit(s). Updating it is a merge, not a fast-forward, so the toolkit survives. Run the script; do not improvise git commands.

```bash
.claude/scripts/bcq-update-fork.sh            # merge + push + report worktrees
.claude/scripts/bcq-update-fork.sh --rebase   # also rebase every clean worktree onto upstream/main
```

What it does:

1. Refuses if `origin` is `microsoft/BCQuality`, if the main checkout is not on `main`, or if it has uncommitted changes (commit toolkit edits first with subject `toolkit: ...`).
2. Fetches both remotes with prune, merges `upstream/main` into `main`, pushes `main` to the fork.
3. Lists every contribution worktree with ahead/behind counts against `upstream/main`; with `--rebase`, rebases the clean ones.

Merge conflicts can only come from upstream touching a file the toolkit also touches (today: `CLAUDE.md` does not exist upstream, `.claude/` does not exist upstream, so none are expected). If one appears, resolve it in favour of upstream for their files and ours for the toolkit, then re-run.

A rebased worktree whose branch was already pushed needs `git push --force-with-lease` from inside the worktree before the PR updates.

Report: the `main` SHA before and after, the count of toolkit commits on top of upstream, and the worktree table.
