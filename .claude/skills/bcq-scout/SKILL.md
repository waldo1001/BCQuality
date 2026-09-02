---
name: bcq-scout
description: Find and triage candidate contributions for the BCQuality community layer. Takes a source folder of existing knowledge (default - the iFacto custom layer), a topic, or a review false positive/negative, and runs every candidate through three gates - admission, overlap, portability. Produces a ranked backlog in .claude/scout/.
argument-hint: "[folder | topic | fp: <what the reviewer got wrong>]"
---

# bcq-scout — triage before you write

BCQuality is a **remedial** knowledge base. The maintainers reject files that are merely true. Scouting exists so you never author something that is generic, duplicated, or company-specific. Every candidate passes three gates or it is dropped with a written reason.

## Inputs

`$ARGUMENTS` is one of:

- **A folder** of existing knowledge articles (default when empty: `/Users/waldo/SourceCode/iFacto/iFactoAcademy/iFacto Playbook/BCQuality/custom/knowledge`). Each `*.md` there is a candidate.
- **A topic** ("permission sets", "PEPPOL e-invoicing", "test generation"). Brainstorm 5–10 concrete BC facts in that area that LLMs get wrong; each is a candidate.
- **`fp:` or `fn:`** followed by what a BCQuality review flagged wrongly or missed. That single pattern is the candidate, authored as negative knowledge (see `skills/write.md`, *Negative knowledge is first-class*).

## Step 0 — refresh the map of what exists

```bash
.claude/scripts/bcq-update-fork.sh
pwsh ./tools/Build-KnowledgeIndex.ps1
```

Scouting runs in the main checkout (`main` = upstream plus the toolkit), so the corpus you compare against is current.

`knowledge-index.json` now lists all articles with `path`, `domain`, `keywords`, `title`, `description`. Read the domain folder listings too: `ls microsoft/knowledge community/knowledge`. Note which domains have a review leaf (`ls microsoft/skills/review/`): an article in a domain without a leaf is never sourced by `al-code-review`.

## Step 1 — extract the BC fact

For each candidate, write one sentence in the form *"BC does X, so Y; an LLM assumes Z."* If you cannot phrase it that way, it is not a knowledge file. Classify the fact:

| Class | Example | Admissible? |
|---|---|---|
| platform mechanic | `OnInstallAppPerCompany` does not fire on version upgrade | yes |
| ordering / signature rule | `SetLoadFields` before filters | yes |
| footgun default | `EventSubscriberInstance` defaults to static | yes |
| CodeCop / AppSourceCop rule | AA0233, AS0103 | yes |
| false-positive guard | boolean page triggers default to `true` | yes |
| generic engineering advice | "keep transactions short" | no |
| company policy / architecture | "every table delegates to a Meth codeunit" | no, unless a BC fact survives stripping |
| product-specific | Distri HIS tables | no |

## Step 2 — Gate A, admission

Ask the README question literally: *if this file did not exist, would a modern LLM reviewing or generating BC code make the mistake?* Answer with a reason, not a feeling. Strong signals: a version-gated API, a property whose default surprises, a name the training data gets backwards, an obsolete signature still widely shown. Weak signals: "important", "best practice", "we always do this".

## Step 3 — Gate B, overlap

```bash
.claude/scripts/bcq-coverage.sh <term1> <term2> ...
```

Use the fact's own vocabulary (API names, property names, trigger names, cop rule ids) plus synonyms. Open every hit and decide:

- **covered** — an existing article states the same fact. Drop, cite the path.
- **delta** — an existing article is adjacent but the fact is distinct (different object, different mechanism, a counter-case). One concern per file, so the delta becomes a *new sibling article* that cross-references the existing one in its Description. Never fold two concerns into one file.
- **new** — no hit.

## Step 4 — Gate C, portability

Strip everything organisation-shaped: names, "mandatory", "company standard", "we", architecture that only makes sense inside one codebase. Re-read what is left. If the remaining text is still a BC fact with a consequence and a detection signal, it ports. If it collapsed into "do it our way", drop it.

Also check that the fact is true for the `bc-version` you will declare. A fact tied to a release (table-field `ToolTip` from BC 24, `InherentPermissions` from BC 22) gets an open-ended range like `[24..]`, not `[all]`.

Anything you are not certain about gets the verdict **verify** with the exact claim to check on Microsoft Learn before authoring. Never author an unverified platform claim.

## Step 5 — write the backlog

Save `.claude/scout/<yyyy-mm-dd>-<source-slug>.md` with a table:

| # | Candidate | Domain (leaf?) | Verdict | Why | Overlap | Proposed slug |

Verdicts: `contribute`, `verify`, `delta`, `covered`, `reject`. Then a short ranked shortlist (max five) of what to author first, preferring domains the maintainers asked for (test generation, AppSource pre-flight, localization, permission sets, upgrade readiness) and facts with the crispest detection signal.

Commit the backlog on `main` with subject `toolkit: scout <source>`. Report the shortlist to the user and stop. Authoring is `/bcq-author` after `bcq-start.sh`.
