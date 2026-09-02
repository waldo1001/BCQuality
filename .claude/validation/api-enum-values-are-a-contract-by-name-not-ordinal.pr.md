## What

Adds one `web-services` article with a good and a bad sample: `community/knowledge/web-services/api-enum-values-are-a-contract-by-name-not-ordinal.md`, `.good.al`, `.bad.al`.

The fact: an API page exposes an enum field as a strongly typed OData enum whose members in `$metadata`, in responses and in `$filter` derive from the AL value **names**. Captions are published separately through `entityDefinitions`; ordinals are not published at all. Dataverse virtual tables model the same enum as a global option set matched by External Name, with the integer values documented as not stable. So renaming a value while keeping its ordinal and caption breaks every consumer, and changing only a caption breaks none. Sources checked on Microsoft Learn: *Transitioning from API v1.0 to API v2.0* (Enums), *Working with Virtual Tables* (Table fields, Enums), AppSourceCop AS0082 and AS0083.

## Why this is a knowledge file (admission test)

A cold reviewer given a diff that changed only the `Caption` of an exposed enum value reported it as a breaking API change, on the stated belief that API pages serialise captions. That is wrong, and a second cold reviewer given the rename diff stated the opposite mechanism, so the model does not know which of name, caption, or ordinal the API carries. The article settles it and carries the false-positive guard explicitly. Honest caveat: the rename half on its own was caught cold when the diff was visible, and AppSourceCop reports a rename as AS0082 when run against a baseline; the article says both. Nothing reports an API field re-pointed to a field of another enum.

## Overlap check

Found by `bcq-scout` and re-checked at validation with a fresh maintainer-role reviewer:

- `microsoft/knowledge/web-services/version-apis-by-adding-not-mutating-published-versions.md` — **delta**. Its contract is the page shape (entity names, fields, keys, behavior) and its signal is a shape change without a new page object. A value rename inside an unchanged field changes none of that, so nothing in it fires. Cross-referenced from the Description.
- `microsoft/knowledge/upgrade/enum-values-additive-at-end.md` — **delta**. It states the opposite carrier ("Persisted rows reference enum members by ordinal, not by name"); under its rule a same-ordinal rename is harmless, across an API boundary it is breaking. Cross-referenced from the Description.
- No existing article mentions `External Name`, Dataverse, virtual tables, or AS0082.
- In flight: open upstream PRs searched by title for the top keywords; none states this fact.

## Sources

- Transitioning from API v1.0 to API v2.0, Enums — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/api-reference/v2.0/transition-to-api-v2.0#enums
- Working with Virtual Tables, Table fields — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/powerplatform/powerplat-entity-modeling#table-fields
- AppSourceCop AS0082 — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0082
- AppSourceCop AS0083 — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0083

The same links sit under `## See also` in the article. `bc-version: [16..]`: the `enum` type is runtime 4.0 (BC 15) and strongly typed enum exposure on API pages is documented with API v2.0 (BC 16).

## Layer and retrieval

Community layer. `microsoft/skills/review/al-web-services-review.md` already sources the `web-services` domain across layers, so no skill change is needed; review fixtures untouched. Happy to see it promoted if it proves itself.

## Scope

Left out on purpose: ordinal stability for persisted rows and page-shape versioning, both already owned by the two cross-referenced Microsoft articles; Dataverse synchronisation (the option-set id mapping in `admin-cds-missing-option-values`) is a different mechanism from virtual tables and is not claimed here.

## Review history

- 2026-09-02, second push: rebased on #147; commit re-authored under a GitHub-linked identity; `bc-version` narrowed to `[16..]`; `false-positive` keyword added; `## See also` with the Learn sources added; bad-sample comment aligned with the article on AS0082; the claim "ordinals are not published at all" replaced by what the docs support.

## Evidence

```
# api-enum-values-are-a-contract-by-name-not-ordinal

Domain: web-services (review leaf: yes). Branch: community/web-services/api-enum-values-are-a-contract-by-name-not-ordinal, rebased on upstream/main 1821809 (#147). Commit author 12088142+waldo1001@users.noreply.github.com (GitHub-linked; the first push was unattributed and would have needed the ruleset's extra approval).
Platform claims checked on Microsoft Learn (2026-09-02): API v2.0 enums are strongly typed, values from `$metadata`, captions from `entityDefinitions` (transition-to-api-v2.0); Dataverse virtual tables match enum values by External Name and document integer values as unstable (powerplat-entity-modeling); AS0082 (rename) and AS0083 (delete) exist and are Upgrade-category rules that need a baseline package.

in-flight: none — open upstream PRs searched by title for api-page, enum, enum-value-name (2026-09-02); #137 (agents guidance) and #132 (self-improvement batch) share the false-positive marker only.
claim: API v2.0 exposes option/enum properties as strongly typed enums; values from `$metadata`, captions from `entityDefinitions` — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/api-reference/v2.0/transition-to-api-v2.0#enums
claim: Dataverse virtual tables model enums as global OptionSets matched by External Name; integer values not guaranteed stable; OptionSet metadata updated on table refresh — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/powerplatform/powerplat-entity-modeling#table-fields
claim: AS0082 forbids renaming an enum value, AS0083 forbids deleting one; both Upgrade-category rules that run against a baseline package — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0082 and -as0083
claim: responses and $filter carry member names, never ordinals — OData v4 JSON enum serialisation (member name as string); the article no longer claims "ordinals are not published at all" because `$metadata` EnumType members may list integer values, which Learn does not settle.
claim (sample comment): compiler silent on a rename, AS0082 fires only against a baseline — rewritten 2026-09-02 so the comment agrees with the article (it previously said "the upgrade rule stays silent").
bc-version: [16..] — the `enum` data type is runtime 4.0 (BC 15, Learn: Enum data type page) and strongly typed enum exposure on API pages is documented with API v2.0 (BC 16, transition-to-api-v2.0#enums); `[all]` would select the bad sample for targets where `enum` does not compile, the reason the reviewer rejected `[all]` on PRs 133 and 134.
precision: a value rename on an enum that no API page exposes, a Caption-only change, and an appended value are the legitimate shapes the signal could match — all three carved out explicitly in the Anti Pattern ("Do not flag a caption change, and do not flag a new value appended at the end"; signal scoped to enums behind a `PageType = API` field). Keyword `false-positive` added, per the 24 corpus articles that use it as the marker.
overlap: microsoft/knowledge/web-services/version-apis-by-adding-not-mutating-published-versions.md — delta — its contract is the page shape ("entity names, fields, keys, and behavior") and its signal is "a breaking shape change without a separate API page object"; a value rename inside an unchanged field leaves shape, entity, fields and keys identical, so nothing in it fires.
overlap: microsoft/knowledge/upgrade/enum-values-additive-at-end.md — delta — it states the opposite carrier: "Persisted rows reference enum members by ordinal, not by name"; under its rule a rename that keeps the ordinal is harmless, across an API boundary it is breaking.
overlap review method: fresh maintainer-role subagent given the new article and each neighbour, asked for COVERED / DELTA / UNRELATED with the deciding sentence quoted (2026-09-02).
cold review (bad sample, neutralised static file): missed — a static file cannot show a rename. The reviewer instead produced adjacent wrong claims: "a value name with a space is not a valid OData identifier", "Extensible = true on an API-exposed enum breaks clients", "captions must be Locked". Noted as evidence that the model's picture of API enum serialisation is unreliable.
cold review (bad sample, neutral PR diff of the rename): caught — "OData/JSON serializes enum members by name, so integrations receive Credit_Memo where they received Credit_Note on an unchanged v1.0". Correct mechanism. The positive rule on its own is weakly remedial for a reviewer who sees the diff.
cold review (neutral PR diff re-pointing the API field to another enum): caught — correct reasons (silent semantic break, no version bump, $metadata type change).
cold review (neutral PR diff changing only the Caption of an exposed value): FALSE POSITIVE — reported as "breaking API contract change: API pages serialize enum fields as strings derived from the value's caption, not its AL name". Wrong per Learn, and the opposite of what the rename reviewer stated. This is the remedial half: the model does not know which of name, caption, or ordinal the API carries.
warm review (bad sample): flagged citing community/knowledge/web-services/api-enum-values-are-a-contract-by-name-not-ordinal.md (one finding, rename at ordinal 2, mechanism and remedy quoted from the article)
warm review (good sample): clean — caption-only change and appended value explicitly not flagged
script: 0 error(s), 0 warning(s) (re-run 2026-09-02 after rebase, attribution fix, See also, false-positive keyword, sample-comment fix)
verdict: ready — article was sharpened after the cold probes so the Description names both failure directions and the Anti Pattern carries the false-positive guard explicitly. State in the PR body that the rename half is caught cold when a diff is visible, and that the caption false positive is the proven remedial part.
```

## Checklist

- [x] Frontmatter has exactly the six required keys; `domain` matches the folder
- [x] `## Description` present; no fenced code blocks; under 100 lines; one concern
- [x] Samples referenced by filename from the article and present next to it
- [x] `validate_frontmatter.py`, `Test-KnowledgeIndex.ps1`, `Test-ReviewFixtures.ps1` pass locally
- [x] Only `community/` is touched
- [x] Commit author is linked to the GitHub account; branch rebased on `upstream/main`

🤖 Generated with [Claude Code](https://claude.com/claude-code)
