# One-off release: Cardmarket expansions from its product catalogue

On 22 November 2026 the operator asked for Cardmarket set names to be checked against Cardmarket's actual dropdown and stored as a reusable set mapping. Operator approval to promote this release: operator, 22 November 2026 ~22:10Z: "Check against cardMarket's actual dropdown. I'd rather store a set mapping we can re-use rather than guess." then ~22:45Z: "Once this is ready, just go ahead and get it deployde, I'm going to bed.". Exact main source: 26fcb320dae90517fd1b55657753568f489e3619, one commit (26fcb320) on the live 67cddb116a5d8453e61015a057218423790f6793. Archive SHA-256: 58e5b94a81c4b2529212f0a5d2d5c71c0c17832c4cfb6f8e4ab03b15f2c537e2. No assertion, retry or release gate is weakened.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-22T23:53:59Z to 2026-11-23T00:26:19Z. Backend units: 4951, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261122T235320Z. Proof inventory: Multichannel proof: 636 passed exactly once (463 standard, 173 recovery); 2 TODOs..

## Runtime scope

Bulk listing submitted nothing after 21 Nov: the first read of Cardmarket's bulk dropdown after 67cddb11 returned nine Magic sets and no Pokemon, so set-name matching cannot work. Cardmarket's published product catalogue (downloads.s3.cardmarket.com productList, singles) gives each product's idExpansion; job cardmarket-product-catalogue stores it for products our CardTrader blueprints reference (channel_cardmarket_product_expansion, Migration20261123000500CardmarketProductExpansion). Bulk items carry that expansion_id, jobs group by it, and worker 1.1.45 opens BulkListing?idExpansion=<id> directly; rows are still filled only for our exact product ids.

Backend diff:

apps/backend/src/jobs/cardmarket-product-catalogue.ts
apps/backend/src/modules/channel-sync/__tests__/cardmarket-set-catalogue.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/cardmarket-worker-postgres.unit.spec.ts
apps/backend/src/modules/channel-sync/cardmarket-bulk-listing.ts
apps/backend/src/modules/channel-sync/cardmarket-set-catalogue.ts
apps/backend/src/modules/channel-sync/migrations/Migration20261123000500CardmarketProductExpansion.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:64a9fe83049cce3946521583e750c1f127569c96e9ceceae924e9c82cf6813b0

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:4063afde7998e11ab77890f63b7f78e0a01c6fde5dd68629c3e685886306175f (67cddb116a5d8453e61015a057218423790f6793); no schema change. No production order, stock or payment mutation is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-23T00:28:09.353Z; live verification pending.

## Verified completion

At 2026-11-23T00:32:16.825Z, three consecutive uncached checks confirmed the new backend and unchanged storefront exact source/digest identities, API health and /gb, all HTTP 200. This task's Cardmarket maintenance drain was resumed and confirmed not draining with zero active jobs. No marketplace write, order replay, inventory repair or payment was performed for deployment verification. No Cardmarket order was changed by deployment verification.

GitOps promotion commit: af9acff42216134b8c5fbf910518920a6dd2a957.
