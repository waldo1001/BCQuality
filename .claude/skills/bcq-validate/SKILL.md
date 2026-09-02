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

It runs inside the worktree, in order: branch and remote guards; change scope against `upstream/main` (only `community/`, no `custom/`, no new top-level); the upstream Python validator; `Test-KnowledgeIndex.ps1`; `Test-ReviewFixtures.ps1`; per-article checks (line count, H1, community tagline, placeholders, company wording, sample presence and references, Good/Bad object names, review-leaf presence, keyword count); sample orphans.

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
- Positive rule: if the cold reviewer **catches** it with a correct reason, the admission test is weak. Record it and tell the user; the maintainers will ask the same question. Sometimes the answer is to sharpen the fact (a more specific mechanic the model still gets wrong), sometimes to drop the file.
- Negative knowledge (false-positive guard): cold-review the neutralised **good** sample instead. If the cold reviewer flags the legitimate pattern, the guard is needed. If it stays clean, the guard is weak.

### Warm review (does the article do its job?)

Spawn a second fresh subagent with the article text plus the bad sample: *"Using only the attached knowledge article as your rule, review this AL file. Report findings as JSON with `id` set to the article's repo-relative path, or an empty list."* Expect one finding that cites the article. Repeat with the good sample; expect an empty list.

- Bad sample not flagged: the Anti Pattern's detection signal is not concrete enough. Rewrite it with the grep-able shape.
- Good sample flagged: the Best Practice is ambiguous or the good sample still contains the pattern. Fix whichever is wrong.

### Record the evidence

Write `.claude/validation/<slug>.md` in the main checkout (it is committed to the fork's `main` as part of the process record, never to the PR):

```
# <slug>
cold review (bad sample): missed | caught — <reviewer's one-line reason>
warm review (bad sample): flagged citing <path> | not flagged
warm review (good sample): clean | flagged — <reason>
script: <errors> error(s), <warnings> warning(s); warnings: <reason each>
verdict: ready | needs work — <what>
```

`/bcq-pr` pastes this into the PR body. Report the verdict to the user with the one thing to fix if it is not ready.
