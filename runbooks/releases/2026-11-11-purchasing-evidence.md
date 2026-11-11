# One-off backend release - purchasing live evidence CSV

## Approval and exact-source validation

On 11 November 2026 the operator approved freezing MVP feature scope and deployment using the established one-off promotion process. The prior release already contains purchasing, cost resolutions and profit reporting. This release adds only read-only evidence export and its Admin download. No Actions workflow, assertion, retry policy or release gate is changed.

Pinned main source: 594ef3a9346a74dd7de30d6e8120dfe4dc247a0c. Full isolated Linux validation passed from 2026-11-11T11:08:19Z to 2026-11-11T11:37:35Z, all six phases successful. Backend units: 4503 passed, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Retained evidence: /srv/freesplash-ci/admin/benchmark-20261111T110741Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 632 passed exactly once (459 standard, 173 recovery); 2 TODOs..

Additional exact-source Windows checks passed: 805 scoped tests, 31 purchasing HTTP journeys, TypeScript, backend/Admin builds; combined-main checks passed 99 targeted tests, three native HTTP journeys, TypeScript and builds. Existing 95 lint warnings, zero errors. Real export proofs cover authentication/private headers, full periods beyond UI pages, frozen values, missing-cost blanks, positive/zero resolutions, signed and cross-window reversals, formula-safe text and unchanged retained data.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:3174310d855133cb937600a127aa805829be47dd2e96b3acc45b85b51ac8f73d
- Validation/build archive SHA-256: 19b53a5514b6c0ea07cb982507cc97bd77b5f4dd676bb81c0b05fcab1c032195
- Previous backend/application rollback target: a595cebf220ea706748c8a9842f28b889ea0b79c, ghcr.io/craigbanach/tcg-store-backend@sha256:198e7742df67099e0b2c55da5370d63440ce36b81c55bf55e545241804f340b7
- Retained storefront: 245313fdf88b730f491fa3b97f60835aad28f96f, ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2

The packaged image passed network-disabled, read-only execution as UID 1000: CSV rendering, formula safety, signed reversals, private-field exclusion and route headers. There are no new migrations relative to the prior live source. The normal managed migration batch remains enabled; failed/uncertain migrations block rollout, with no database rollback or forced replay.

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Existing credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. No provider listing update, order replay, dispatch, physical-stock change, accounting posting or synthetic production purchase is authorised by this release. The CSV is live evidence, not a closed pack or Manager import; missing manual expenses remain undetectable. Prior-window adjustments, revenue corrections and returns remain deferred beyond MVP.

Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, and Nomad is healthy. Resume only this task's nonce. The previous immutable backend is the application-only rollback target; no schema rollback is attempted.

Submitted at 2026-11-11T11:38:02.0778212Z. Verified rollout remains pending; image publication or manifest push alone is not success.