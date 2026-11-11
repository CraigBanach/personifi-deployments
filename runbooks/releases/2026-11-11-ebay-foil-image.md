# One-off backend release - eBay foil image recovery and approved main

## Operator approval and exact-source validation

On 11 November 2026 the operator requested the established one-off promotion after GitHub Actions refused to start because of account billing/spending limits (run 42932283471). The operator separately approved including the unreleased purchasing, profit and shared-dispatch changes and database migrations on main. The storefront image is retained. No Actions workflow or validation gate was changed.

Pinned main source: a595cebf220ea706748c8a9842f28b889ea0b79c. Full isolated Linux validation passed from 2026-11-11T01:16:06Z to 2026-11-11T01:44:48Z, all six phases successful. Backend units: 4484 passed, zero failed. Browser checks: 105 read-only and 38 stateful; zero unexpected or flaky outcomes. Retained evidence: /srv/freesplash-ci/admin/benchmark-20261111T011527Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 632 passed exactly once (459 standard, 173 recovery); 2 TODOs..

The initial local full suite exposed five stale shared-fulfilments harness failures after the dispatch review component was added. A test-only follow-up supplies the opaque child and asserts that opening review does not dispatch. No source assertion, retry setting, suite or release gate was skipped. Full isolated proof also exposed a cross-module migration-name collision: the not-yet-released purchasing sales-cost migration was renamed from timestamp 20261110170000 to 20261110170001, retaining the same schema and forward boundary. A fresh disposable migration and native hold proof passed after this correction.

## Immutable images and scope

- New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:198e7742df67099e0b2c55da5370d63440ce36b81c55bf55e545241804f340b7
- Matching validation/build source archive SHA-256: 37f54c5df1e4d98c00f51603229021a4d87ae33bb4bc3a88ab9fc14d520f1e15
- Previous backend: d57b47ebdf9290bdf3342f51ad288b5f36f988bc, ghcr.io/craigbanach/tcg-store-backend@sha256:97d23f3c1834e0032257c330e6a0820e592c673af0af62e0a83ca077d4865cf3
- Preserved storefront: 245313fdf88b730f491fa3b97f60835aad28f96f, ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2

The packaged backend passed network-disabled/read-only verification as UID 1000, including an actual mocked-upstream JPEG render. Foil rendering now supports Scryfall image sources with an identifying User-Agent and bounded nonredirecting fetch. An explicit per-product revision and exact-listing command refresh images through the normal account coordinator, reviewed ownership, product workflow, one-shot journaled listing transport and independent provider readback. It retains remote price, stock, content, policies and item identity; routine creation-only content preservation remains enabled.

This backend also includes the explicitly approved pending purchasing cost snapshots and open-window resolutions, reviewed revenue/profit reporting, shared-stock actual dispatch and FIFO cost journaling, and SortSwift condition preservation. Four new migrations relative to the previous backend are managed by the ordinary serialized migration batch. The source-only homepage sort change is not promoted into the retained storefront image.

## Managed rollout and separate operational refresh

A task-owned Cardmarket maintenance drain acknowledged zero active jobs before manifest submission. Managed migrations, Nomad readiness and GitOps reconciliation remain enabled. Credentials, feature gates, config/catalog apply flags and storefront digest are preserved. Failed or uncertain migration blocks rollout and requires inspection; no database rollback or automatic replay is attempted. The previous immutable backend above is the application rollback target only.

Keep this task's drain nonce until exact backend source/digest, unchanged storefront source/digest, API health and /gb pass three consecutive public checks and Nomad is healthy. Resume only this task's nonce. The owner-approved image refresh for variant variant_01M73PVR9Y1S9EXGX61M731YNY / existing eBay listing 137920042008 is a separate post-rollout operation; promotion itself performs no listing refresh, order replay, dispatch, physical-stock change or catalog/config script.

Submitted at 2026-11-11T01:45:10.2226364Z. Completion is verified below; image publication or manifest push alone was not treated as success.

## Verified completion

- At 01:48:57 UTC, three consecutive public checks verified backend source `a595cebf220ea706748c8a9842f28b889ea0b79c` / digest `sha256:198e7742df67099e0b2c55da5370d63440ce36b81c55bf55e545241804f340b7`, the unchanged storefront source/digest above, API health and `/gb` (all HTTP 200).
- Nomad version 321, deployment `4edfd559`, is successful. Backend allocation `61439e91` is running/healthy; the previous allocation completed normally. The managed migration gate completed before service rollout. This task's worker-maintenance nonce was resumed successfully with zero active jobs and no remaining drain.
- The revised Doubling Season renderer URL returned HTTP 200, `image/jpeg`, 318,721 bytes. The explicit image-refresh preview proposed only `explicit_foil_image_refresh` for the exact variant and existing item.
- At 01:51:35 UTC the confirmed refresh completed through operation `chebayop_01M744TCWM8RFH6C0B48F23C10`, fingerprint `9e41293471754ce74898f2745a685fdb1e90b43a2fe015409a78486abfb101af`. Both provider steps were journaled and independent account-verified readback completed. The retained offer is `353179348011`, item `137920042008`, active, quantity one, seller price GBP 182.01. Description, aspects, condition and policies are unchanged. Only the image URL acquired `revision=scryfall-fix-20261111`; the product workflow retained that exact per-product revision.
- The first CLI preview invocation rejected missing parsed arguments before target mutation; the deployed Medusa exec command was then invoked programmatically with the exact argument array. Preview and confirmation used the same revision. No uncertain operation was replayed, no direct independent eBay writer was used and no item was recreated.
- The public eBay page refused automated retrieval with HTTP 403, so public/app cache display is not claimed. Provider acceptance and the working revised JPEG are verified; app caches may take time to update.

The superseded validation attempts are retained separately. The final accepted isolated run `/srv/freesplash-ci/admin/benchmark-20261111T011527Z` passed all six phases, 4,484 backend unit tests, 632 stock-safety cases exactly once and 143 passing browser cases with zero unexpected/flaky outcomes (two existing browser skips, two stock-safety TODOs). No release gate or retry setting was weakened.
