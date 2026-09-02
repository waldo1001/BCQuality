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
