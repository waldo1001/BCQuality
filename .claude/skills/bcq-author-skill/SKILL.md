---
name: bcq-author-skill
description: Author a community action skill for BCQuality (community/skills/) following the DO contract - frontmatter, the five sections, leaf vs super-skill, and the findings-report output. Use for the maintainers' wish list (test generation, AppSource pre-flight, localization, permission sets, upgrade readiness) or any new review/generation capability.
argument-hint: "<skill-id> <one-line goal>"
---

# bcq-author-skill — mechanics only, facts elsewhere

A skill is a **finder and applier**. It says how to discover, filter, worklist, and emit. Every BC fact it would act on must already be a knowledge file it can cite. If the knowledge does not exist yet, author it first with `/bcq-author`; a skill with nothing to cite returns `no-knowledge` and helps nobody.

## Step 0 — read the contracts, live

- `skills/do.md` — the template, the output contract, agent-finding precision bar, composition rules.
- `skills/entry.md` — how Entry discovers and goal-matches skills (`description` and `id` are what it scores).
- `skills/read.md` — matching semantics your Relevance step must apply.
- One reference leaf: `microsoft/skills/review/al-<nearest-domain>-review.md`. Copy its structure, not its text.

## Step 1 — decide the shape

- **Leaf** (default): evaluates knowledge files directly; no `sub-skills`.
- **Super-skill**: composes leaves via `sub-skills`; flat only, and validator rule R26 requires a super-skill's `sub-skills` to equal the `al-*-review.md` siblings in *its own directory*. For community skills that means: either no `sub-skills`, or you ship the leaves next to it with that naming.
- Location: `community/skills/<area>/<id>.md`. `id` must be unique across all layers (R24); a community skill sharing an `id` with a Microsoft skill *overrides* it by layer precedence, which is almost never what you want.

## Step 2 — scaffold

Start a worktree first (`.claude/scripts/bcq-start.sh skills <id>` creates `community/skills/<id>` from `upstream/main`), then copy `.claude/templates/action-skill.md` to `community/skills/<area>/<id>.md` inside it and replace the placeholders. Frontmatter keys: `kind: action-skill`, `id`, `version: 1`, `title`, `description`, `inputs`, `outputs: [findings-report]`, plus optional `bc-version`, `technologies`, `countries`, `application-area`, `sub-skills`. Unknown keys warn (R15); missing required ones fail.

- `inputs`: pick from `pr-diff`, `object-list`, `file-path`, `repository`, `telemetry-query` (others warn). Any-of semantics: the skill must return `not-applicable` when the supplied subset is insufficient.
- `description`: write it in the vocabulary of the goals it should match ("permission set review", "AppSource pre-flight check"). Entry scores exact keyword overlap first.

## Step 3 — the five sections, in order, once each (R21)

1. `## Source` — which `domain` rows of `knowledge-index.json` to take, across layers. Do not open articles here.
2. `## Relevance` — the READ matching rules against the task context; how unknown dimensions cap confidence.
3. `## Worklist` — the task-specific signal: object types, triggers, property names, tokens from the diff that select an article. Name the article to load and the diff shape that selects it. Do **not** restate the article's reasoning (cite, don't copy). Say when to return `not-applicable`.
4. `## Action` — severity mapping, confidence rules, agent-finding bar, `suggested-code` policy, outcome selection.
5. `## Output` — "Conforms to the DO output contract", the `findings[].domain` display label, and one populated JSON example whose `id` equals `references[0].path` and whose path really exists.

## Step 4 — prove it by hand

There is no evaluation harness for community skills (fixtures cover `microsoft/skills/review/` only), so do a manual dry run and paste it in the PR:

1. `pwsh ./tools/Build-KnowledgeIndex.ps1`
2. Take an existing `.bad.al` from the domain as the input; execute the skill's four steps yourself; emit the JSON.
3. Check the JSON is strict RFC 8259 (quotes and newlines escaped), the cited path exists and was opened, and the `.good.al` counterpart yields no finding.

Then `.claude/scripts/bcq-validate.sh <id>` (it runs the validator, which checks R15–R26 for action skills) and continue with `/bcq-pr`, commit subject `skill(<id>): <what it reviews>`.
