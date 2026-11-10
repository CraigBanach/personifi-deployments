# One-off release - exact historical Cardmarket exclusions and approved main

## Explicit operator scope

The operator requested resolution of Cardmarket exceptions and exclusion of three owner-confirmed pre-integration orders, while leaving unlinked listings untouched. After being warned that main also contained unshipped purchasing work, the operator explicitly selected Deploy latest main, including those changes, subject to full validation. Pinned main source: d57b47ebdf9290bdf3342f51ad288b5f36f988bc. This remains backend-only; the existing storefront source and digest are preserved. No config/catalog apply is requested.

## Validation and immutable image

Full isolated Linux exact-source validation passed from 2026-11-10T20:13:12Z to 2026-11-10T20:42:46Z, all six phases successful. Backend units: 4369 passed, zero failed. Browser passes: 105 read-only and 38 stateful; no unexpected or flaky outcomes. Stock-safety inventory: Multichannel proof: 632 passed exactly once (459 standard, 173 recovery); 2 TODOs.. Retained Linux evidence: /srv/freesplash-ci/admin/benchmark-20261110T201234Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. No GitHub Actions dispatch or workflow edits were used.

- New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:97d23f3c1834e0032257c330e6a0820e592c673af0af62e0a83ca077d4865cf3
- Matching source/archive SHA-256: 270192244fb6178cb1d71566f13bba9eca9479d77df2759e7a3b767b8794791f
- Previous backend: 0742bab6697a913c03d04ffb8761515681b95724, ghcr.io/craigbanach/tcg-store-backend@sha256:963d12808408ba710f66f4b81d211c940cb8b9523ef36477034293e39bebcb41
- Preserved storefront: 245313fdf88b730f491fa3b97f60835aad28f96f, ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2

The packaged image passed network-disabled/read-only inspection as UID 1000, including the exact-order historical command, immutable exclusion migration, account-scoped staging/intake/Actions filters, database fences on commitment/sale/financial admission and stale-snapshot rejection. The operator-approved purchasing collection preview and cost-acceptance routes are packaged too. Local source unit tests passed (4,740 tests); disposable Cardmarket SQL proofs passed (74 cases), including competing writers and stale transaction isolation. These local numbers are supplementary, not substitutes for the exact-main validation above.

The first exact-source run, /srv/freesplash-ci/admin/benchmark-20261110T182946Z, had one stateful storefront quick-add keyboard test pass only on its configured retry (zero unexpected failures). The strict promotion summarizer refused it. Its trace, context, reports and browser-flake-review.json are retained: ArrowDown preceded a React passive-effect fetch, consistent with an existing hydration/timing race. No source, assertion, retry setting or promotion gate was relaxed. The independent full validation cited above used a fresh disposable VM and the identical source/archive/workflow; its browser outcomes were all clean. The storefront image remains unchanged.

## Operational changes and retained evidence

Nine existing sealed articles were individually reconciled through the normal binding command against fresh exact article/product/finish/language/price evidence, with shared availability checked and unresolved sold-article evidence refused. A retained maintenance receipt records original snapshots and native observed publication baselines. All nine original attempts remain unchanged; this is explicit existing-article adoption, not a claim that their old submissions succeeded or authority to replay them. Subsequent normal existing-article sync confirmed all nine are capped by Cardmarket; no cap was bypassed and no duplicate listing was submitted. All 35 original recovery snapshots remain unchanged, including the spent Togetic refusal. The five reviewed/unlinked native articles remain unbound and untouched.

The experimental read-only exact-ID worker lookup (1.1.40, c943851) returned no positive routes and encountered a human challenge during the Pokemon batch. After the operator cleared it, one additional read encountered the same challenge and was stopped without another retry. The generic product redirect lookup was removed: version 1.1.41, local home-server source e0481a0, restores runtime background.js byte-for-byte to proven 1.1.39 source 887a139, retaining two regression tests against generic redirects. All 88 worker safety tests and the unchanged four deployment/drain tests pass. Versioned rollouts drain before restart and resume through their own retained nonce; no running native job, uncertain attempt or browser fence was reset. All route/identity holds remain pending positive evidence; no unverified candidate was published.

## Managed migration, rollout and recovery

This backend adds one immutable historical-exclusion migration and includes two purchasing collection/cost migrations approved as part of latest main. Serialized managed migration runs before service rollout; an uncertain/failed batch is retained and blocks rollout rather than being purged or replayed. Previous application image above is the rollback target, not a database rollback. Retained review/cost rows block unsafe down migrations.

A task-owned maintenance drain confirmed zero active browser jobs before manifest submission. Preserve its nonce until exact backend source/digest, unchanged storefront source/digest, API health and /gb pass three consecutive public checks and Nomad is healthy. Then use the newly deployed guarded command for only orders 1293612373, 1304335937 and 1310589333. It refuses any original already owning stock or a native financial order; it records the owner decision without rewriting sale observations, changing the global cutoff, reserving stock, creating an order or sending a cancellation. Resume only this task's nonce after read-only verification.

## Submitted promotion

Submitted at 2026-11-10T20:45:07.7902740Z. Verified rollout and exact historical exclusions pending; image publication or manifest push alone is not success.