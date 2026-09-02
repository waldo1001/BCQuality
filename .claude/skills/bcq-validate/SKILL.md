---
name: bcq-validate
description: Validate a BCQuality contribution before the PR - runs the exact upstream CI checks locally (frontmatter validator, knowledge index, review fixtures), the contributor guards (scope, custom layer, top-level, company wording), and a cold/warm review proof that demonstrates the article is remedial. Writes the evidence to .claude/validation/.
argument-hint: "[<slug>]"
---

# bcq-validate — prove it before you ship it

Two halves. The script does everything deterministic; you do the review proof.

## Half 1 — deterministic checks

```bash
.claude/scripts/bcq-validate.sh <slug>      # targets .claude/worktrees/<slug>
```

It runs inside the worktree, in order: branch and remote guards; commit attribution (author email linked to the GitHub account); change scope against `upstream/main` (only `community/`, no `custom/`, no new top-level); the upstream Python validator; `Test-KnowledgeIndex.ps1`; `Test-ReviewFixtures.ps1`; per-article checks (line count, H1, community tagline, placeholders, company wording, sample presence and references, Good/Bad object names, review-leaf presence, keyword count); sample orphans.

Fix every error and re-run. Warnings are allowed only with a one-line reason you will put in the PR body.

## Half 2 — the review proof

The admission test says a file earns its place only if an LLM would get the point wrong without it. Demonstrate that instead of asserting it. For each changed article `<dir>/<slug>.md` in the worktree:

### Cold review (does the model already know?)

First neutralise the sample, because the file name, the `Good`/`Bad` object names, and the comments all leak the verdict (a cold reviewer once answered "the core defect the sample is about"):

```bash
.claude/scripts/bcq-neutralize.sh .claude/worktrees/<slug>/community/knowledge/<domain>/<slug>.bad.al
```

Spawn a **fresh subagent** (it has no memory of this conversation or the article) with only the neutral copy's path and this prompt: *"You are reviewing this Business Central AL file for defects. List every concrete defect with a one-line reason. If it is clean, say so."* Do not mention the article, the domain, or the expected finding.

- Positive rule: if the cold reviewer **misses** the defect, the file is remedial. Record the miss.
- **A cold reviewer that contradicts the article is a claim to verify, not a false positive to record.** Before labelling any cold answer wrong, check the reviewer's mechanism on Microsoft Learn as if it were a candidate fact. On PR 149 the "false positive" that carried the admission case was a correct description of OData schema 1.0; the article had only described 2.0, and the maintainer caught it. If the reviewer's answer holds in some context (an older runtime, another schema version, another client type), the article is missing that context, and the sharper fact is usually "the behaviour depends on X", which is a stronger admission case than either half.
- Positive rule: if the cold reviewer **catches** it with a correct reason, the admission test is weak. Record it and tell the user; the maintainers will ask the same question. Sometimes the answer is to sharpen the fact (a more specific mechanic the model still gets wrong), sometimes to drop the file.
- Negative knowledge (false-positive guard): cold-review the neutralised **good** sample instead. If the cold reviewer flags the legitimate pattern, the guard is needed. If it stays clean, the guard is weak.

### Warm review (does the article do its job?)

Spawn a second fresh subagent with the article text plus the bad sample: *"Using only the attached knowledge article as your rule, review this AL file. Report findings as JSON with `id` set to the article's repo-relative path, or an empty list."* Expect one finding that cites the article. Repeat with the good sample; expect an empty list.

- Bad sample not flagged: the Anti Pattern's detection signal is not concrete enough. Rewrite it with the grep-able shape.
- Good sample flagged: the Best Practice is ambiguous or the good sample still contains the pattern. Fix whichever is wrong.

### Overlap review (Gate B, checked again)

"Already on BCQuality" is a block, not a warning. The scout's overlap verdict is re-checked here because `/bcq-author` can also start from a topic, without a scout run.

```bash
.claude/scripts/bcq-overlap.sh .claude/worktrees/<slug>/community/knowledge/<domain>/<slug>.md
```

It lists every existing article sharing two or more frontmatter keywords with yours, plus every article yours cites. For each neighbour, spawn a **fresh subagent** as the maintainer: give it the new article and the neighbour and ask for exactly one of `COVERED` (the neighbour already states the central fact), `DELTA` (adjacent, but a distinct fact or consequence), or `UNRELATED`, with the deciding sentence quoted.

- Any `COVERED` verdict ends the contribution: record it, tell the user, and do not open a PR. Sharpening the fact is allowed only if the sharpened version is re-scouted.
- Every `DELTA` neighbour must be cross-referenced from the article's Description.
- Half 1 fails until every neighbour has a recorded verdict (see the `overlap:` lines below).

### Claim ledger (what the reviewer actually checks)

The only outside contribution ever rejected on content had a wrong premise and a bad sample showing an error that does not happen; the maintainer traced the sample line by line and cited Microsoft Learn. So, before the PR: list every behavioural claim in Description, Best Practice and Anti Pattern, and every claim made in a sample comment, and give each a Learn URL (`microsoft_docs_search` / `microsoft_docs_fetch`) or an observed run. A claim with neither is rewritten until it has one, or removed. Put the URLs in the article's `## See also` and the ledger in the evidence file as `claim:` lines.

### Context check

Every BC behaviour that varies by runtime, schema version, client type, session type, or SaaS/on-premises must say which context the rule holds in, in the title or the first Description sentence, and the detection guard must not suppress a finding outside that context. An unscoped rule is both a wrong article and a wrong carve-out.

### Precision check (the maintainers' dominant change request)

Read the Anti Pattern as the reviewer will: is the detection signal broader than the defect? Name the legitimate shape it would also match and confirm the article carries an explicit carve-out for it. Every open change request on upstream as of 2026-09-02 was this question. Record a `precision:` line.

### In-flight overlap

`gh pr list --repo microsoft/BCQuality --state open --search "<keyword>"` for the two or three strongest keywords. An open PR stating the same fact ends the contribution the same way `COVERED` does. Record an `in-flight:` line.

### Record the evidence

Write `.claude/validation/<slug>.md` in the main checkout (it is committed to the fork's `main` as part of the process record, never to the PR):

```
# <slug>
overlap: <neighbour path> — covered | delta | unrelated — <deciding sentence>   (one line per neighbour listed by bcq-overlap.sh)
in-flight: none | PR #n — <same fact | adjacent>
claim: <claim> — <Learn URL | observed: how>   (one line per claim in the article and the sample comments)
bc-version: <range> — <runtime floor of the APIs used in the article and samples, with the Learn page that states it>
precision: <the legitimate shape the signal could match> — carved out in <section>
cold review (bad sample): missed | caught — <reviewer's one-line reason>
warm review (bad sample): flagged citing <path> | not flagged
warm review (good sample): clean | flagged — <reason>
script: <errors> error(s), <warnings> warning(s); warnings: <reason each>
verdict: ready | needs work — <what>
```

`/bcq-pr` pastes this into the PR body. Report the verdict to the user with the one thing to fix if it is not ready.
