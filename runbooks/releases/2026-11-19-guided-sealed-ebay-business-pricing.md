# One-off release: guided sealed purchasing, eBay business pricing switch, picked-dispatch re-stage fix

On 19 November 2026 the operator explicitly requested deployment of all of origin/main through the established one-off process ("Take the other changes with you"). Exact main source: 809c0a8cc7767215d0712779ee92f55449caf792, three commits on the live a8d81bdca74298cad029ca925d791c6224a792a5 (728f12e2 guided sealed purchasing, 0debe8b3 eBay business pricing, 809c0a8c picked-dispatch re-stage observation-error fix); this is the whole of origin/main at pin time. Archive SHA-256: f95e299dc6f2ebe097e46259f2beaf7fdb429aa77f11ac9e65ef5d994ab77778. No assertion, retry or release gate is weakened. The workflow adds the isolated guided sealed PostgreSQL proof; the reviewed local mirror includes that proof plus the full purchasing HTTP suite and 20 zero-retry quick-add repetitions.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-19T15:20:10Z to 2026-11-19T15:51:48Z. Backend units: 4924, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261119T151930Z, local orders-channel-release-20261119. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

New purchases use a guided existing-product, quantity, exact GBP unit-cost and required-bin flow. Saving moves no stock. Whole-delivery confirmation atomically records the receipt, stock/bin increments and immutable acquisition lots, with retry protection. First slice supports single-variant one-to-one inventory; no partial arrivals, shared case/box stock, kits or singles collections. Existing units stay unknown-cost; forward FIFO reserves earlier packed demand before later dispatches. A minute job freezes eligible dispatched COGS without moving stock. Cancellation/drift requires reconciliation, not historical rewriting. Legacy entry points remain accessible; their rollout gates stay independent.

Migration20261119140000 is additive: nullable stock_purchase.workflow and empty immutable plan/scope/lot/allocation tables. No historical backfill, purchase receipt, catalogue change or inventory adjustment occurs in the migration. Purchase pur_ba6c92c5e0574fba9a062f8b44cf77f0 and all existing inventory/history are explicitly outside this task. Exact-source disposable proofs: 10 PostgreSQL cases and 33 full purchasing HTTP cases passed; guided UI tests and backend/Admin build pass.

eBay business pricing (0debe8b3): Channels → eBay → Business pricing stores a business fee % and per-item fixed fee (additive Migration20261119120000EbayBusinessPricing, table channel_ebay_business_pricing) laid over the reviewed listing config publish.businessPricing at load. The release sets nothing; eBay prices change only when the operator saves the panel, which queues every live listing for a price-only update. A new ebay-price-sync job (every 5 minutes, no-op when the queue is empty) drains open requests.

Picked-dispatch re-stage (809c0a8c): the hourly re-stage CTE now selects the observation error it filters on; its first run may re-stage one older eligible original once (expected).

Backend diff:

apps/backend/integration-tests/fixtures/purchasing/src/api/admin/purchases/sealed/[id]/arrive/route.ts
apps/backend/integration-tests/fixtures/purchasing/src/api/admin/purchases/sealed/route.ts
apps/backend/integration-tests/http/purchasing.spec.ts
apps/backend/package.json
apps/backend/src/admin/__tests__/guided-sealed-purchases.unit.spec.ts
apps/backend/src/admin/__tests__/purchase-products-ui.unit.spec.ts
apps/backend/src/admin/components/ebay-business-pricing.tsx
apps/backend/src/admin/components/guided-sealed-purchases.tsx
apps/backend/src/admin/components/legacy-purchases.tsx
apps/backend/src/admin/routes/channels/page.tsx
apps/backend/src/admin/routes/purchases/page.tsx
apps/backend/src/api/admin/channel-sync/ebay/business-pricing/route.ts
apps/backend/src/api/admin/purchases/sealed/[id]/arrive/route.ts
apps/backend/src/api/admin/purchases/sealed/route.ts
apps/backend/src/jobs/ebay-price-sync.ts
apps/backend/src/jobs/guided-sealed-costs.ts
apps/backend/src/modules/channel-sync/__tests__/ebay-picked-dispatch-restage.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/ebay-price-sync.unit.spec.ts
apps/backend/src/modules/channel-sync/adapters/ebay-lifecycle-config.ts
apps/backend/src/modules/channel-sync/adapters/ebay-picked-dispatch-restage.ts
apps/backend/src/modules/channel-sync/ebay-price-sync.ts
apps/backend/src/modules/channel-sync/migrations/Migration20261119120000EbayBusinessPricing.ts
apps/backend/src/modules/ebay/__tests__/business-pricing-setting.unit.spec.ts
apps/backend/src/modules/ebay/business-pricing-setting.ts
apps/backend/src/modules/purchasing/__tests__/sealed-fifo.unit.spec.ts
apps/backend/src/modules/purchasing/__tests__/sealed-purchases-postgres.unit.spec.ts
apps/backend/src/modules/purchasing/__tests__/stock-events.unit.spec.ts
apps/backend/src/modules/purchasing/ledger.ts
apps/backend/src/modules/purchasing/migrations/Migration20261119140000.ts
apps/backend/src/modules/purchasing/sales-costs.ts
apps/backend/src/modules/purchasing/sealed-fifo.ts
apps/backend/src/modules/purchasing/sealed-purchases.ts
apps/backend/src/modules/purchasing/stock-events.ts
apps/backend/src/modules/purchasing/stock-posting.ts
apps/backend/test-scripts/guided-sealed-local.cjs

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:58abfdb1d45b2e1e36b48bd71df8816377b8d9cfa84879eb540bf7dfde738408

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:1b4dbe434a891ff5343996825377baefdfee4fec03f10e9462f327b44a2a7cce (a8d81bdca74298cad029ca925d791c6224a792a5); retain additive tables. Once guided receipts exist, require reviewed recovery rather than schema rollback or manual stock replay. No production purchase/stock/payment mutation or config/catalog script is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-19T15:52:14.064Z; live verification pending.
