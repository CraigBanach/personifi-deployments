# One-off release: eBay originals already shipped at first import; collect-in-person sales

On 19 November 2026 the operator requested this change ("Do A. Collect-in-person orders should be supported too") be deployed through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is a8d81bdca74298cad029ca925d791c6224a792a5 (one commit on top of the live d8ea94c828ce51bfd78768f0093f287dd44b56d5; this is the whole of origin/main at pin time), archive SHA-256 5cbb6833e93ba99e2e4638c4db4895d24fc4575c8d4a6ea3dd507ead40623926.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-19T13:42:32Z to 2026-11-19T14:10:58Z. Backend units: 4900, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261119T134152Z, local orders-channel-release-20261119. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

1. An eBay stock original shipped on eBay before it could import (19-15430-53074, damaged Midnight Hunt collector box, dispatched on eBay 19 Nov 12:40 while blocked) now imports through the ordinary stock reservation, which still refuses without availability, and appears in the pick run. A new hourly runtime step re-stages the latest eBay observation of an imported, uncancelled, pending original once all its plugin picks have completed after that observation and it has no shipment effect; the existing lifecycle then records eBay's shipment from the completed pick. This also covers orders shipped on eBay before they were picked.

2. Collect-in-person eBay sales (PREPARE_FOR_PICKUP; e.g. 27-15405-13868) import with no delivery address. The canonical sale carries collect_in_person: true only for such sales, so existing sale fingerprints are unchanged; unknown or multiple fulfilment instructions still go to review.

The one-off migration script retry-ebay-shipped-and-collection-orders deletes channel_ebay_order_backfill rows whose prior_error is ebay_source_requires_review and which have no channel_sale, so the hourly backfill re-drives each such original once more; any still failing re-block as before.

No schema change. Local multichannel eBay proofs (170) passed before pinning. Backend diff:

apps/backend/src/migration-scripts/retry-ebay-shipped-and-collection-orders.ts
apps/backend/src/modules/channel-sync/__tests__/ebay-picked-dispatch-restage.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/ebay-source.unit.spec.ts
apps/backend/src/modules/channel-sync/adapters/ebay-picked-dispatch-restage.ts
apps/backend/src/modules/channel-sync/adapters/ebay-processing.ts
apps/backend/src/modules/channel-sync/adapters/ebay-runtime.ts
apps/backend/src/modules/channel-sync/adapters/ebay-source.ts
apps/backend/src/modules/channel-sync/source-sale.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:1b4dbe434a891ff5343996825377baefdfee4fec03f10e9462f327b44a2a7cce

Rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:3b70437160b16966baae45dc4847dd0c0c9a8007b4cd094c2314e3eaa562f839 (d8ea94c828ce51bfd78768f0093f287dd44b56d5). No schema change, order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-19T14:11:24.002Z; live verification pending.
