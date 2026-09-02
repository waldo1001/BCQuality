# api-enum-values-are-a-contract-by-name-not-ordinal

Domain: web-services (review leaf: yes). Branch: community/web-services/api-enum-values-are-a-contract-by-name-not-ordinal, rebased on upstream/main c39f723.
Platform claims checked on Microsoft Learn (2026-09-02): API v2.0 enums are strongly typed, values from `$metadata`, captions from `entityDefinitions` (transition-to-api-v2.0); Dataverse virtual tables match enum values by External Name and document integer values as unstable (powerplat-entity-modeling); AS0082 (rename) and AS0083 (delete) exist and are Upgrade-category rules that need a baseline package.

cold review (bad sample, neutralised static file): missed — a static file cannot show a rename. The reviewer instead produced adjacent wrong claims: "a value name with a space is not a valid OData identifier", "Extensible = true on an API-exposed enum breaks clients", "captions must be Locked". Noted as evidence that the model's picture of API enum serialisation is unreliable.
cold review (bad sample, neutral PR diff of the rename): caught — "OData/JSON serializes enum members by name, so integrations receive Credit_Memo where they received Credit_Note on an unchanged v1.0". Correct mechanism. The positive rule on its own is weakly remedial for a reviewer who sees the diff.
cold review (neutral PR diff re-pointing the API field to another enum): caught — correct reasons (silent semantic break, no version bump, $metadata type change).
cold review (neutral PR diff changing only the Caption of an exposed value): FALSE POSITIVE — reported as "breaking API contract change: API pages serialize enum fields as strings derived from the value's caption, not its AL name". Wrong per Learn, and the opposite of what the rename reviewer stated. This is the remedial half: the model does not know which of name, caption, or ordinal the API carries.
warm review (bad sample): flagged citing community/knowledge/web-services/api-enum-values-are-a-contract-by-name-not-ordinal.md (one finding, rename at ordinal 2, mechanism and remedy quoted from the article)
warm review (good sample): clean — caption-only change and appended value explicitly not flagged
script: 0 error(s), 0 warning(s)
verdict: ready — article was sharpened after the cold probes so the Description names both failure directions and the Anti Pattern carries the false-positive guard explicitly. State in the PR body that the rename half is caught cold when a diff is visible, and that the caption false positive is the proven remedial part.
