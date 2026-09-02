---
name: bcq-author
description: Author one BCQuality community knowledge article with its good/bad AL samples, from a scouted candidate, a topic, or by porting an article from a custom layer. Enforces the READ/WRITE contracts, the community conventions, and the admission test.
argument-hint: "<domain> <slug> | <path/to/source-article.md> | <topic sentence>"
---

# bcq-author — one concern, one file, two samples

## Step 0 — preconditions (all must hold)

1. Work inside the contribution worktree, never in the main checkout: `.claude/scripts/bcq-start.sh <domain> <slug>` prints the path (`.claude/worktrees/<slug>`, branch `community/<domain>/<slug>` from `upstream/main`). Every file path below is relative to that worktree.
2. Read the live contracts before writing a word. They are the source of truth, this skill only adds conventions:
   - `skills/read.md` (schema, matching, sample-file rules)
   - `skills/write.md` (atomicity, sections, frontmatter choices, pre-PR checklist)
3. Read two neighbouring articles in the target domain (one `microsoft/`, one `community/` if present) for tone and length.
4. Read the scout backlog entry for this candidate in `.claude/scout/` (main checkout); it names the overlap to cross-reference and any claim still marked `verify`. A candidate whose verdict is `covered` is never authored: the fact is already on BCQuality, and a duplicate PR is closed, not merged. Without a backlog entry (topic input), run `.claude/scripts/bcq-overlap.sh` on the scaffolded article as soon as its keywords exist, and stop if a neighbour already states the fact.

## Step 1 — pick the domain

Use an existing domain folder name. Prefer one with a review leaf (`microsoft/skills/review/al-<domain>-review.md`); without a leaf the article is invisible to `al-code-review`. The frontmatter `domain` must equal the folder name (validator rule R27). A brand-new domain is allowed but needs a sentence of justification in the PR.

## Step 2 — scaffold

```bash
.claude/scripts/bcq-new-article.sh <domain> <slug> "Title"     # scaffolds inside .claude/worktrees/<slug>
```

Slug rules: kebab-case, echoes the concern, no version numbers, no company prefix. Good: `enum-implementation-lets-test-apps-inject-doubles`. Bad: `testing-tips`, `ifacto-...`.

## Step 3 — write the article

Frontmatter: **exactly** the six keys. Nothing else, not `author`, not `title` (R02 rejects extras). Defaults: `bc-version: [all]`, `technologies: [al]`, `countries: [w1]`, `application-area: [all]`. Use `[N..]` when the fact is release-gated **or when the article or either sample uses an API with a runtime floor** (the reviewer rejected `[all]` twice because "the bad sample would be selected for older targets where the call does not compile"); name the floor and its source in the PR. `keywords`: 3–10, lowercase kebab-case, the search terms an engineer would type, including synonyms (`findset`, `find-set`); never the domain or the company name.

Body:

- `# Title` — a full sentence stating the rule or the fact ("Install code does not run during a version upgrade").
- `> Contributions welcome — open a PR to refine or extend this article.` — community convention, directly under the title (most merged articles have it; not enforced).
- `## Description` — 2–5 sentences: the BC mechanic, why the wrong assumption is natural, the consequence. This is the retrieval target; write it so an agent can decide relevance from this paragraph alone. Say plainly what LLMs get wrong, the corpus does this ("LLMs are largely unaware the manual model exists").
- `## Best Practice` — the *what* and *why*; end with ``See sample: `<slug>.good.al`.``
- `## Anti Pattern` — the pattern, the consequence, a `Detection signal:` sentence a reviewer can grep for, and the **carve-out**: the legitimate shape that must not be flagged. The signal is never broader than the defect; "scope the finding, preserve the deliberate case as a valid exception" is the maintainers' most frequent change request. End with ``See sample: `<slug>.bad.al`.``
- `## See also` — the Microsoft Learn URLs that back the claims (one line each, `Title, section — URL`), plus the originating review finding when the article generalises one (BCApps PR discussion link). Recent merged articles do this and the reviewer praised it. Non-normative: no load-bearing content there.
- Scope the fact to its context. If the behaviour differs by runtime, OData schema version, client type, or session type, say so in the title or the first sentence, and make the carve-out conditional on that context.
- Wording: `must` only where the documentation mandates it (the reviewer downgrades unsupported "must" to "should"); quote documented property names and keywords verbatim; `bc-version` never claims a release the docs do not tie the fact to.
- Negative knowledge (a false-positive guard, or an article whose Anti Pattern includes a wrong review finding) adds the `false-positive` keyword; 24 corpus articles use it as the marker.

Never: fenced code blocks (R10), more than 100 lines (R11; aim under 50), two concerns, "and" joining two topics in the Description, organisation names, "mandatory".

## Step 4 — write the samples

- Self-contained, compile-plausible AL; never lifted from base-app source.
- Object ids in the 50100 range; object name ends in `Good` / `Bad` (the evaluation harness neutralises those tokens, so it is the convention).
- The bad sample shows exactly the anti pattern and nothing else; one full-line comment naming the defect is fine (the harness strips full-line comments).
- The good sample is the bad sample fixed, not a different program: the two differ only in the property the article teaches. Length follows readability; merged samples run 25–100 lines. Each sample must read stand-alone (the reviewer opens it without the article).
- Sample comments must agree with the code and with the article; a comment that contradicts either is a change request on its own ("contradicts its own code").
- Object ids: samples are demonstration-only, so ids may repeat across the corpus; never claim they are unique unless `grep -rl "<id>" */knowledge` says so.
- Both files must be referenced by filename from the article (R28) and any referenced file must exist (R28).

Layer: author in `community/`. Placement is the maintainers' call; they move generally applicable content to `microsoft/` before merge or promote it monthly. Never argue placement in the PR; an invitation to promote is welcome.

Domain notes: `testing` content is reviewed by the BCApps test owners against their library idioms (no hardcoded messages, `Assert.Expected*` helpers, enqueue in the test and dequeue in the handler, `Initialize()` clearing `LibraryVariableStorage`, `AssertEmpty()` at the end). Read `microsoft/knowledge/testing/ui-handlers-in-tests.md` and its samples before writing a testing sample.

## Step 5 — porting from a custom layer (when the input is a source article)

1. Copy the fact, not the policy. Delete every "iFacto", "Distri", "company standard", "mandatory", "we".
2. Rewrite imperatives as consequences: "must do X" becomes "BC does Y, so X avoids Z".
3. Drop the `ifacto` keyword and the `ifacto-` slug prefix; re-derive keywords from the fact.
4. Re-check `bc-version`: company rules often say `[all]` for release-gated features.
5. Re-derive the detection signal; company rules often detect by naming convention, which does not port.
6. Cross-reference any adjacent upstream article found by `/bcq-scout` in the Description.
7. Rewrite the samples from scratch if they contain company object names or affixes.

## Step 6 — self-check, then hand off

Run the pre-PR checklist at the end of `skills/write.md` line by line, then:

```bash
.claude/scripts/bcq-validate.sh <slug>
```

Continue with `/bcq-validate <slug>` for the review proof. Do not open a PR from this skill.
