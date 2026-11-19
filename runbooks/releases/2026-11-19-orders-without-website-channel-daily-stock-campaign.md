# One-off release: marketplace orders without website-channel membership; daily stock-campaign refresh

On 19 November 2026 the operator requested this change be deployed through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is d8ea94c828ce51bfd78768f0093f287dd44b56d5 (three commits on top of the live c167d925e79ee534fd6668ac43836faae9885665: e4a12270, a2ddfdad and d8ea94c8; this is the whole of origin/main at pin time; attempt 1 pinned a2ddfdad and failed three multichannel proofs that still asserted the removed stock-channel rule, which d8ea94c8 updates), archive SHA-256 cf82e804fc7ad72272638e2c56b9971515e6314b350e0264a0ce787e2b3e7b36.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-19T11:40:51Z to 2026-11-19T12:10:42Z. Backend units: 4895, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261119T114011Z, local orders-channel-release-20261119. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

1. Marketplace orders no longer require website sales-channel membership. eBay line mapping, native import verification and CardTrader order mapping stop requiring the product (or its reviewed stock location) to be in the website stock channel; published/managed/no-backorder/component checks are unchanged. eBay 19-15430-53074 (damaged Midnight Hunt collector box, eBay channel only) was blocked by this. The one-off migration script retry-ebay-channel-blocked-orders deletes channel_ebay_order_backfill rows whose prior_error is ebay_source_requires_review and which have no channel_sale, so the hourly backfill re-drives each such original once more; any still failing re-block as before.

2. The stock-campaign-changed subscriber is removed. It rechecked every campaign candidate (~2.5 minutes) on every product/stock event, leaving Medusa's event queue ~16 hours behind (Cardmarket #210 and an eBay import were waiting for their payment events). The stock-campaign-drafts job now runs daily at 05:00 UTC, paging the catalogue then rechecking candidates once; review/approval still re-read live stock. The backlog drains once events stop waiting on the subscriber.

No schema change. No order is replayed by deployment beyond the bounded eBay backfill retry above. Backend diff:

apps/backend/integration-tests/http/multichannel-consistency.spec.ts
apps/backend/src/admin/components/stock-updates.tsx
apps/backend/src/jobs/stock-campaign-drafts.ts
apps/backend/src/lib/__tests__/stock-campaign-preparation-health.unit.spec.ts
apps/backend/src/lib/stock-campaign-preparation-health.ts
apps/backend/src/lib/stock-campaign-preparation.ts
apps/backend/src/migration-scripts/retry-ebay-channel-blocked-orders.ts
apps/backend/src/modules/channel-sync/__tests__/cardtrader-order-mapping.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/ebay-order-lines.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/import-verification.unit.spec.ts
apps/backend/src/modules/channel-sync/adapters/cardtrader-order-mapping.ts
apps/backend/src/modules/channel-sync/adapters/ebay-order-mapping.ts
apps/backend/src/modules/channel-sync/import-verification.ts
apps/backend/src/modules/purchasing/__tests__/stock-events.unit.spec.ts
apps/backend/src/subscribers/stock-campaign-changed.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:3b70437160b16966baae45dc4847dd0c0c9a8007b4cd094c2314e3eaa562f839

Rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:ab07f176a174a04a2b55899ddcca33e5abb8e327d899a5480eb7da6aa927df6b (c167d925e79ee534fd6668ac43836faae9885665). No schema change, order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-19T12:11:04.509Z; live verification pending.
