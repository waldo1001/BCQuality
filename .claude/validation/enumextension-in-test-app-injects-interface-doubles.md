# enumextension-in-test-app-injects-interface-doubles

cold review (neutralised bad sample, fresh Sonnet reviewer, no article): **missed** — it did not mention that the dispatch enum is closed or that no test double can be injected; its top finding claimed `TierImpl := Tier` (enum-to-interface assignment) is not valid AL, which it is. The model neither knows the seam nor trusts the dispatch mechanism.
cold review, first attempt (un-neutralised file): caught — but it wrote "the core defect the sample is about", i.e. the file name and `Bad` tokens leaked the verdict. That run is void; it produced the neutralisation step.
warm review (bad sample, article as the only rule): flagged citing `community/knowledge/testing/enumextension-in-test-app-injects-interface-doubles.md`, line 2, severity minor, signal "enum that implements an interface without Extensible = true".
warm review (good sample, article as the only rule): clean — `Extensible = true` on the production enum, mock value and codeunit only in the test-app `enumextension`.
script: 0 error(s), 0 warning(s) (validator, knowledge index, review fixtures, contributor checks all green)
overlap: microsoft/knowledge/interfaces/assign-codeunit-to-interface-for-testability.md (setter injection when the consumer owns the dependency; this article covers record-driven dispatch where no setter exists), microsoft/knowledge/interfaces/prefer-interface-over-case-branching.md (the dispatch pattern itself, no testing angle). No article mentions enumextension as a test seam.
verdict: ready
