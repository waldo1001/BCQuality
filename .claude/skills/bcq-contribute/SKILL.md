---
name: bcq-contribute
description: End-to-end workflow to contribute to the microsoft/BCQuality community layer from this fork - update the fork, scout candidates, start an isolated worktree, author the article and samples, validate against the upstream CI and a cold/warm review proof, open the PR, and track it. Use for "contribute X to BCQuality", "port this rule upstream", or "open a BCQuality PR".
argument-hint: "[<domain> <slug> | <source-article.md> | <topic> | skill <idea>]"
---

# bcq-contribute — the whole loop

This is the orchestrator. It calls the other `bcq-*` skills in order and stops at the two points where only the user can decide. Read `CLAUDE.md` first; it holds the hard rules and the worktree model.

```
update-fork ─▶ scout ─▶ [pick] ─▶ start worktree ─▶ author ─▶ validate ─▶ [confirm] ─▶ pr ─▶ status ─▶ finish
```

## Interpret `$ARGUMENTS`

| Input | Meaning | Path |
|---|---|---|
| empty | interactive pick from the company guidelines | `/bcq-from-guidelines` (list → check → choose → contribute) |
| `<domain> <slug>` | a scouted candidate; the backlog in `.claude/scout/` has the details | start → author |
| a path ending in `.md` | port that article from a custom layer | scout (single) → start → author |
| a sentence | author from expertise on that topic | scout (topic) → start → author |
| `skill <idea>` | a community action skill instead of knowledge | `/bcq-author-skill` |
| `fp: ...` / `fn: ...` | negative knowledge from review feedback | scout (single) → start → author |

## Steps

1. **Update the fork** — `/bcq-update-fork`. Abort on a merge conflict or a dirty main checkout.
2. **Scout** — `/bcq-scout` with the input. If more than one candidate survives, present the shortlist and **stop for the user to pick** (autonomous runs: take the top-ranked `contribute` verdict and say so). Never author a `verify` verdict before the claim is checked on Microsoft Learn.
3. **Start** — `.claude/scripts/bcq-start.sh <domain> <slug>` creates `.claude/worktrees/<slug>` on `community/<domain>/<slug>` from `upstream/main`. All authoring happens in that path; the main checkout stays on `main`.
4. **Author** — `/bcq-author <domain> <slug>`. One article per worktree by default; up to three closely related articles in one domain are acceptable when the maintainers would review them together.
5. **Validate** — `/bcq-validate <slug>`. Fix and re-run until zero errors. Every warning gets a sentence in the PR body or a fix.
6. **PR** — `/bcq-pr <slug>`. Pushing the branch and opening a PR against Microsoft are outward-facing: show the final title and body and **wait for an explicit yes**.
7. **Status** — `/bcq-status` to watch CI, answer review comments, and record the PR in `.claude/contributions.md`. After the merge: `bcq-finish.sh <slug>` and `/bcq-update-fork`.

## Ground rules that never bend

- One concern per file, under 100 lines, six frontmatter keys, no fenced code, samples referenced by name.
- Only `community/` changes in the PR. `custom/` is auto-closed. New top-level entries get flagged. The toolkit never enters a worktree.
- Strip company identity: the fact ports, the policy does not.
- Verified facts only. If a platform claim cannot be confirmed from Microsoft Learn or the corpus, do not ship it.
- Small PRs with a story: the fact, why an LLM gets it wrong, what already exists nearby, and the evidence from the neutralised cold review and the warm review.
