---
name: bcq-from-guidelines
description: Interactive flow to contribute one company guideline to the BCQuality community layer - lists what the iFacto custom layer could contribute, checks each against what upstream already has, lets the user pick a topic, then authors, validates, and opens the PR. Use for "what could I contribute from our guidelines", "pick something to contribute", or "contribute one of our rules".
argument-hint: "[source-folder]"
---

# bcq-from-guidelines — from company rule to community PR, one pick at a time

Four beats: **list → check → choose → contribute**. Two decisions belong to the user: which topic, and the final go for the push and PR. Everything else runs without asking.

Source folder: `$ARGUMENTS` if given, else `/Users/waldo/SourceCode/iFacto/iFactoAcademy/iFacto Playbook/BCQuality/custom/knowledge`.

## 1. List and check (reuse the backlog when it is fresh)

```bash
.claude/scripts/bcq-update-fork.sh
.claude/scripts/bcq-backlog-status.sh
```

- `FRESH` → load the latest `.claude/scout/*-ifacto-custom-layer.md`. It already holds, per company article, the verdict, the overlap paths, and the proposed slug.
- `STALE` (new upstream articles, or company guidelines changed) → run `/bcq-scout` on the source folder first. The scout writes a new backlog with the `Corpus at triage time` line and a `Source fingerprint:` line so the next status check can compare. The status script prints which company articles the old backlog never saw; those are the ones to look at closely.

Never present a verdict older than the corpus it was checked against.

## 2. Present the menu

Show the user a compact table of every candidate with verdict `contribute`, `verify`, or `delta`, in that order, each with: the company article, the BC fact in one sentence, the domain, the overlap (what upstream already has and why this is distinct), and what still needs verification. Then list the `covered` and `reject` ones in one line each so the user sees why they are not on the menu.

Ask with `AskUserQuestion`: one question, the top candidates as options (max four; add "show me the rest" as an option when there are more), with a recommendation marked. Wait for the answer. In an autonomous run, stop here and report the menu; do not pick for the user.

## 3. Verify, then contribute

For a `verify` candidate, check the open claim on Microsoft Learn (`microsoft_docs_search` / `microsoft_docs_fetch`) before writing anything. If the claim does not hold, say so, mark the backlog row `reject` with the reason, and return to the menu.

Then run the loop with the chosen `<domain>` and `<slug>`:

1. `.claude/scripts/bcq-start.sh <domain> <slug>` — worktree from `upstream/main`.
2. `/bcq-author <domain> <slug>` with the company article as the source to port (strip policy, keep the fact, cross-reference the overlap found in step 1).
3. `/bcq-validate <slug>` — CI checks plus the neutralised cold review and the warm review. Iterate until `ready`.
4. `/bcq-pr <slug>` — show the title and body, ask once with `AskUserQuestion` ("Push and open this PR against microsoft/BCQuality?"), then push and create.
5. Update the backlog row to `contributed (PR #n)` and the ledger; commit both on `main` with subject `toolkit: ledger`.

Report: the PR URL, the CI status, and the next best candidate from the menu.
