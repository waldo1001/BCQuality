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

## Evidence

```
# api-enum-values-are-a-contract-by-name-not-ordinal

Domain: web-services (review leaf: yes). Branch: community/web-services/api-enum-values-are-a-contract-by-name-not-ordinal, rebased on upstream/main c39f723.
Platform claims checked on Microsoft Learn (2026-09-02): API v2.0 enums are strongly typed, values from `$metadata`, captions from `entityDefinitions` (transition-to-api-v2.0); Dataverse virtual tables match enum values by External Name and document integer values as unstable (powerplat-entity-modeling); AS0082 (rename) and AS0083 (delete) exist and are Upgrade-category rules that need a baseline package.

overlap: microsoft/knowledge/web-services/version-apis-by-adding-not-mutating-published-versions.md — delta — its contract is the page shape ("entity names, fields, keys, and behavior") and its signal is "a breaking shape change without a separate API page object"; a value rename inside an unchanged field leaves shape, entity, fields and keys identical, so nothing in it fires.
overlap: microsoft/knowledge/upgrade/enum-values-additive-at-end.md — delta — it states the opposite carrier: "Persisted rows reference enum members by ordinal, not by name"; under its rule a rename that keeps the ordinal is harmless, across an API boundary it is breaking.
overlap review method: fresh maintainer-role subagent given the new article and each neighbour, asked for COVERED / DELTA / UNRELATED with the deciding sentence quoted (2026-09-02).
cold review (bad sample, neutralised static file): missed — a static file cannot show a rename. The reviewer instead produced adjacent wrong claims: "a value name with a space is not a valid OData identifier", "Extensible = true on an API-exposed enum breaks clients", "captions must be Locked". Noted as evidence that the model's picture of API enum serialisation is unreliable.
cold review (bad sample, neutral PR diff of the rename): caught — "OData/JSON serializes enum members by name, so integrations receive Credit_Memo where they received Credit_Note on an unchanged v1.0". Correct mechanism. The positive rule on its own is weakly remedial for a reviewer who sees the diff.
cold review (neutral PR diff re-pointing the API field to another enum): caught — correct reasons (silent semantic break, no version bump, $metadata type change).
cold review (neutral PR diff changing only the Caption of an exposed value): FALSE POSITIVE — reported as "breaking API contract change: API pages serialize enum fields as strings derived from the value's caption, not its AL name". Wrong per Learn, and the opposite of what the rename reviewer stated. This is the remedial half: the model does not know which of name, caption, or ordinal the API carries.
warm review (bad sample): flagged citing community/knowledge/web-services/api-enum-values-are-a-contract-by-name-not-ordinal.md (one finding, rename at ordinal 2, mechanism and remedy quoted from the article)
warm review (good sample): clean — caption-only change and appended value explicitly not flagged
script: 0 error(s), 0 warning(s)
verdict: ready — article was sharpened after the cold probes so the Description names both failure directions and the Anti Pattern carries the false-positive guard explicitly. State in the PR body that the rename half is caught cold when a diff is visible, and that the caption false positive is the proven remedial part.
```

## Checklist

- [x] Frontmatter has exactly the six required keys; `domain` matches the folder
- [x] `## Description` present; no fenced code blocks; under 100 lines; one concern
- [x] Samples referenced by filename from the article and present next to it
- [x] `validate_frontmatter.py`, `Test-KnowledgeIndex.ps1`, `Test-ReviewFixtures.ps1` pass locally
- [x] Only `community/` is touched

🤖 Generated with [Claude Code](https://claude.com/claude-code)
