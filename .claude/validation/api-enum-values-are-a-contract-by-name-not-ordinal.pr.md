## What

Adds one `web-services` article with a good and a bad sample: `community/knowledge/web-services/api-enum-values-are-a-contract-by-name-not-ordinal.md`, `.good.al`, `.bad.al`.

The fact: what an API page publishes for an enum field depends on the OData `$schemaversion` the caller receives. Under schema 2.0 the field is a strongly typed enum and `$metadata`, responses and `$filter` carry the AL member names, with captions published separately through `entityDefinitions`. Under schema 1.0 the same field is `Edm.String` and responses carry the en-US caption. Microsoft's API v2.0 is always 2.0; custom APIs defaulted to 1.0 through BC 23, to 2.0 from BC 24, and a caller can still pin 1.0. The ordinal is never the carrier. Dataverse virtual tables match by External Name.

## Why this is a knowledge file (admission test)

Three fresh cold reviewers, given a BC 22 custom API (schema 1.0 by default), each asserted one carrier as universal. The caption-only change was called "safe for API consumers, confidence high" because "API pages serialize enum fields by the enum member name, never by caption", which is wrong for the schema this app serves. The rename reviewer caught the schema 2.0 break but stated captions "only affect the UI". The knowledge probe put `Edm.String` in `$metadata` with the name in the payload, a mix of both schemas, with an invented version cutoff. The model does not know that the schema version decides, and is confident in both wrong directions. With the article, the caption-only diff on the BC 22 app is flagged with the correct mechanism and the reviewer states it would not have flagged it otherwise.

## Overlap check

- `microsoft/knowledge/web-services/version-apis-by-adding-not-mutating-published-versions.md` — **delta**: page-shape contract; a value or caption change inside an unchanged field changes none of it. Cross-referenced.
- `microsoft/knowledge/upgrade/enum-values-additive-at-end.md` — **delta**: persisted rows bind by ordinal; across an API boundary the carrier is the name (2.0) or the caption (1.0). Cross-referenced.
- No existing article mentions `$schemaversion`, `entityDefinitions`, External Name, virtual tables, or AS0082.
- In flight: open upstream PRs searched by title for the top keywords; none states this fact.

## Sources

- Deprecated features in the platform, schema version for custom APIs (default changed in BC 24) — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/upgrade/deprecated-features-platform#changes-in-2024-release-wave-1-version-240
- Transitioning from API v1.0 to API v2.0, Enums and Schema version — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/api-reference/v2.0/transition-to-api-v2.0#enums
- Working with Virtual Tables, Table fields — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/powerplatform/powerplat-entity-modeling#table-fields
- AppSourceCop AS0082 — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0082, AS0083 — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0083
- Schema 1.0 payload shape (caption as `Edm.String`) as cited in the review — https://www.kauffmann.nl/2024/08/22/custom-apis-and-schemaversion-2-0/

`bc-version: [17..]`: API v2.0 and schema 2.0 exist from BC 17.

## Layer and retrieval

Community layer. `microsoft/skills/review/al-web-services-review.md` already sources the `web-services` domain across layers, so no skill change is needed; review fixtures untouched. Happy to see it promoted if it proves itself.

## Scope

Left out on purpose: ordinal stability for persisted rows and page-shape versioning, owned by the two cross-referenced Microsoft articles; Dataverse data synchronisation (option-set id mapping) is a different mechanism from virtual tables and is not claimed.

## Review history

- Round 1 (2026-09-02): opened with the caption/name rule stated as universal; the "false positive" cold probe in the evidence was a correct schema 1.0 answer.
- Round 2 (2026-09-02, after the change request): title, Description, Best Practice, Anti Pattern and the detection guard scoped to schema 2.0, with schema 1.0 stated as the caption contract and the carve-out conditional on establishing 2.0; custom APIs that may be called as 1.0 preserve both contracts or version; `bc-version` moved to `[17..]`; good sample keeps names and captions and shows append plus `ObsoleteState`; cold probes re-run on a BC 22 app, warm reviews re-run; the withdrawn probe is marked as such in the Evidence block. Also: rebased on #144, commit re-authored under a linked identity, `## See also` and `false-positive` keyword added.

## Evidence

```
# api-enum-values-are-a-contract-by-name-not-ordinal

Domain: web-services (review leaf: yes). Branch: community/web-services/api-enum-values-are-a-contract-by-name-not-ordinal, rebased on upstream/main 82422f9 (#144). Commit author 12088142+waldo1001@users.noreply.github.com (GitHub-linked).

Round 2 (2026-09-02, after JesperSchulz's change request): the article is now scoped to the OData schema version. Under 2.0 the member name is the carrier; under 1.0 the field is `Edm.String` and the caption is the carrier; custom APIs defaulted to 1.0 through BC 23 and to 2.0 from BC 24, and a caller can still pin 1.0. The round-1 "false positive" cold probe was a correct answer for schema 1.0 and is withdrawn as evidence.

in-flight: none — open upstream PRs searched by title for api-page, enum, enum-value-name (2026-09-02).
claim: under schema 2.0 enum properties are strongly typed; values from `$metadata`, captions from `entityDefinitions` — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/api-reference/v2.0/transition-to-api-v2.0#enums (API v2.0 "is always set to 2.0")
claim: custom APIs: "Starting in version 24, the default value of $schemaversion is set to 2.0, also for custom APIs"; before that, 2.0 had to be requested explicitly — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/upgrade/deprecated-features-platform#changes-in-2024-release-wave-1-version-240
claim: under schema 1.0 the enum property is `Edm.String` and the payload carries the en-US caption; under 2.0 the member name — maintainer-cited walkthrough https://www.kauffmann.nl/2024/08/22/custom-apis-and-schemaversion-2-0/ (CustomerLevel: 'Gold Level' on 1.0, 'GOLD' on 2.0); Learn states the 2.0 side and the default change, not the 1.0 payload shape explicitly
claim: API v2.0 introduced in 2020 release wave 2 (BC 17) — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/upgrade/deprecated-features-w1#changes-in-2024-release-wave-1
claim: Dataverse virtual tables match enum values by External Name; integer values not stable — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/powerplatform/powerplat-entity-modeling#table-fields
claim: AS0082 forbids renaming, AS0083 deleting an enum value; Upgrade-category rules that need a baseline — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0082 and -as0083
claim (sample comments): bad = rename with ordinal and caption kept, schema 2.0 consumers break, AS0082 needs a baseline; good = names and captions kept, value appended, value obsoleted — both agree with the article.
bc-version: [17..] — API v2.0 and schema 2.0 start at BC 17 (maintainer: "The frontmatter should start at BC17").
precision: the legitimate shapes are a caption change where every consumer is on schema 2.0, and an appended value; both carved out explicitly. The carve-out is conditional on establishing schema 2.0; on a custom API where 1.0 is possible a caption change is reported, not suppressed.
context: the rule names its context (schema 2.0 vs 1.0, BC 17–23 default vs BC 24+, explicit `$schemaversion` pin) in the title and the first Description sentence.
overlap: microsoft/knowledge/web-services/version-apis-by-adding-not-mutating-published-versions.md — delta — page-shape contract and signal; a value or caption change inside an unchanged field leaves shape, entity, fields and keys identical.
overlap: microsoft/knowledge/upgrade/enum-values-additive-at-end.md — delta — persisted rows bind by ordinal; across an API boundary the carrier is the name (2.0) or the caption (1.0).
cold review (rerun, fresh reviewer, caption-only diff on a BC 22 custom API, app.json runtime 11.0): MISSED — "safe for API consumers ... API pages serialize enum fields by the enum member name, never by caption or ordinal. Confidence: high." Wrong for the schema 1.0 this app serves by default: the payload changes from 'Credit Note' to 'Credit Memo'.
cold review (rerun, fresh reviewer, rename diff, same app): caught the schema 2.0 break with the correct name mechanism, but stated "captions only affect the UI, and ordinals are never exposed on API pages" and did not know schema 1.0 consumers see no payload change. Half right, no schema awareness.
cold review (rerun, fresh reviewer, knowledge question, no files): MISSED — "$metadata: Edm.String ... JSON: the AL value name ... captions are not used on API pages", a mix of the 1.0 metadata and the 2.0 payload, with a made-up v15 cutoff. Confidence "high".
remedial for: the model does not know that the carrier depends on the OData schema version, and confidently asserts one carrier as universal in both directions.
warm review (bad sample): flagged citing community/knowledge/web-services/api-enum-values-are-a-contract-by-name-not-ordinal.md (one finding, rename at ordinal 2 on an API-exposed enum, mechanism and remedy from the article)
warm review (good sample): clean — names and captions kept, ReturnOrder appended, Quote obsoleted
warm review (caption-only diff, BC 22 custom API, consumer schema unknown): flagged citing the article — "custom API on platform 22 defaults to schema 1.0 ... consumer-visible contract change ... keep the caption or publish a new APIVersion"; reviewer states it would not have flagged this without the article.
script: 0 error(s), 0 warning(s) (2026-09-02, round 2, after rebase on 82422f9)
verdict: ready — round 2 addresses every point of the change request; remaining reviewer-side judgement is whether "another reliable context signal" is specific enough.
```

## Checklist

- [x] Frontmatter has exactly the six required keys; `domain` matches the folder
- [x] `## Description` present; no fenced code blocks; under 100 lines; one concern
- [x] Samples referenced by filename from the article and present next to it
- [x] `validate_frontmatter.py`, `Test-KnowledgeIndex.ps1`, `Test-ReviewFixtures.ps1` pass locally
- [x] Only `community/` is touched
- [x] Commit author is linked to the GitHub account; branch rebased on `upstream/main`

🤖 Generated with [Claude Code](https://claude.com/claude-code)
