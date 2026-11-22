# One-off release: Cardmarket set mapping

On 22 November 2026 the operator asked for Cardmarket set names to be checked against Cardmarket's actual dropdown and stored as a reusable set mapping. Operator approval to promote this release: operator, 22 November 2026 ~22:10Z: "Check against cardMarket's actual dropdown. I'd rather store a set mapping we can re-use rather than guess." then ~22:45Z: "Once this is ready, just go ahead and get it deployde, I'm going to bed.". Exact main source: 67cddb116a5d8453e61015a057218423790f6793, one commit (67cddb11) on the live 13a1c92fd4a9c3425099175e01e199d4533f0483. Archive SHA-256: 950d445560aeb2c35132f1aaa21a11d8736a72b3c7a8c6f32ac8ffe4deab1fc8. No assertion, retry or release gate is weakened.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-22T23:03:58Z to 2026-11-22T23:37:24Z. Backend units: 4949, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261122T230319Z. Proof inventory: Multichannel proof: 636 passed exactly once (463 standard, 173 recovery); 2 TODOs..

## Runtime scope

Cardmarket bulk listing matched sets by exact name, so 23 singles whose shop set name differs from Cardmarket's were skipped as expansion_not_found. Worker 1.1.44 reads the bulk listing expansion dropdown (read_expansions) into channel_cardmarket_expansion; the owner maps each unmatched shop set once on Channels -> Cardmarket -> Listings (channel_cardmarket_set_rule, Migration20261122230000CardmarketSetMapping); bulk listing then sends the dropdown's exact name and id. Unmapped sets behave as before.

Backend diff:

apps/backend/src/admin/components/cardmarket-channel.tsx
apps/backend/src/admin/components/cardmarket-set-mapping.tsx
apps/backend/src/api/admin/channel-sync/cardmarket/[id]/set-mapping/refresh/route.ts
apps/backend/src/api/admin/channel-sync/cardmarket/[id]/set-mapping/retire/route.ts
apps/backend/src/api/admin/channel-sync/cardmarket/[id]/set-mapping/route.ts
apps/backend/src/jobs/cardmarket-bulk-listing.ts
apps/backend/src/modules/channel-sync/__tests__/cardmarket-set-catalogue.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/cardmarket-worker-postgres.unit.spec.ts
apps/backend/src/modules/channel-sync/cardmarket-bulk-listing.ts
apps/backend/src/modules/channel-sync/cardmarket-set-catalogue.ts
apps/backend/src/modules/channel-sync/cardmarket-uncertain-recovery.ts
apps/backend/src/modules/channel-sync/cardmarket-worker.ts
apps/backend/src/modules/channel-sync/migrations/Migration20261122230000CardmarketSetMapping.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:4063afde7998e11ab77890f63b7f78e0a01c6fde5dd68629c3e685886306175f

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:ac4eae749fbded4e4e897930d450a95444652f13e428bdedfff818794a00e1de (13a1c92fd4a9c3425099175e01e199d4533f0483); no schema change. No production order, stock or payment mutation is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-22T23:39:07.279Z; live verification pending.

## Verified completion

At 2026-11-22T23:41:44.708Z, three consecutive uncached checks confirmed the new backend and unchanged storefront exact source/digest identities, API health and /gb, all HTTP 200. This task's Cardmarket maintenance drain was resumed and confirmed not draining with zero active jobs. No marketplace write, order replay, inventory repair or payment was performed for deployment verification. No Cardmarket order was changed by deployment verification.

GitOps promotion commit: c39afb4cc6e847ebbfc308b682db59b6acf6821d.
