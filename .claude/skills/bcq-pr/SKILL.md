---
name: bcq-pr
description: Commit, push to the fork, and open a pull request against microsoft/BCQuality main for a validated community contribution. Applies the commit convention, builds the PR body from the template with the validation evidence, and requires explicit confirmation before creating the PR.
argument-hint: "[<slug>]"
---

# bcq-pr — small PR, full story

## Preconditions

All git commands below run inside the worktree: `cd .claude/worktrees/<slug>`.

1. `.claude/scripts/bcq-validate.sh <slug>` exits 0, and `.claude/validation/<slug>.md` (main checkout) exists with verdict `ready`. If not, stop and run `/bcq-validate <slug>`.
2. Branch is rebased: `.claude/scripts/bcq-update-fork.sh --rebase` from the main checkout.
3. `git status` in the worktree shows only `community/` changes.
4. `git log -1 --format=%ae` shows an email linked to the GitHub account (this repo's local config uses `<id>+<login>@users.noreply.github.com`). An unattributed commit shows `author: null` on GitHub and triggers the upstream ruleset's extra-approval requirement; fix with `git commit --amend --reset-author`.

## Commit

Stage only the article and its samples (the toolkit cannot be in the worktree, but be explicit anyway):

```bash
git add community/knowledge/<domain>/<slug>.md community/knowledge/<domain>/<slug>.good.al community/knowledge/<domain>/<slug>.bad.al
```

Subject conventions observed upstream:

- one article: `knowledge(<domain>): <what the rule says, lowercase, imperative or declarative>`
- several articles: `knowledge: <summary>`
- action skill: `skill(<id>): <what it reviews>`

Body: two or three sentences on the fact and why it is remedial, then the trailer required by this harness (`Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`). Commit as the user; attribution in BCQuality is the git author, never a frontmatter key.

## Build the PR body

Fill `.claude/templates/pr-body.md`:

- **What** — one paragraph: the fact, the domain, the files added.
- **Why this is a knowledge file** — the admission-test answer in two sentences, naming what an LLM gets wrong.
- **Overlap check** — the adjacent articles found by `/bcq-scout` and one line each on why this one is distinct (or "no existing article mentions X"), plus the in-flight line (open upstream PRs searched, none on this fact).
- **Sources** — the Learn URLs behind each claim, so the reviewer can verify without asking.
- **Evidence** — paste `.claude/validation/<slug>.md`.
- Keep the checklist; tick what is true.

Title = the commit subject. Maintainers squash-merge with the PR title; freeform titles merge too, the convention is ours.

## Confirm, then create

Show the user the exact title and body. Pushing the branch to the public fork and creating a PR on a Microsoft repository are outward-facing: **wait for an explicit yes**, then push and create in one go. In an autonomous run without a user, stop before pushing: leave the branch committed locally and the body saved at `.claude/validation/<slug>.pr.md`. A branch on the public fork is already published content.

```bash
git push -u origin community/<domain>/<slug>
gh pr create --repo microsoft/BCQuality --base main --head waldo1001:community/<domain>/<slug> --title "<subject>" --body-file .claude/validation/<slug>.pr.md
```

Then:

```bash
gh pr checks <number> --repo microsoft/BCQuality
gh api "repos/microsoft/BCQuality/actions/runs?event=pull_request&head_sha=$(git rev-parse HEAD)" --jq '.workflow_runs[]|{name,status,conclusion}'
```

`gh pr checks` shows only `flag`, `guard` and `license/cla` for a first-time contributor. The three validators (frontmatter, knowledge index, review fixtures) are `pull_request` workflows and sit at `conclusion: action_required` until a maintainer approves the run. Report that state as "validators awaiting maintainer approval", never as green; the local `bcq-validate.sh` run is the only validation evidence until then.

Add a row to `.claude/contributions.md` in the main checkout (`| <date> | <PR URL> | <domain>/<slug> | open |`) and commit it there with subject `toolkit: ledger`. Report the URL and the CI result.
