# One-off release: eBay hourly sync capacity fix; Seller Hub listings-left entry

On 23 November 2026 the operator approved releasing the eBay hourly-sync fix now through the established one-off process ("Yes, release now"). Exact main source: f472ee542561e8a93c5158c39954542de57ca663, two commits (63d426bc hourly sync capacity; f472ee54 the operator-requested "listings left this month" admin entry: "Just give me a setting that allows me to put in how many listings are left for the month") on the live 26fcb320dae90517fd1b55657753568f489e3619; this is the whole of origin/main at pin time. Archive SHA-256: 39bccdde3846a194ef2cdd31ffdab3ae149e6cf281cdc8b95bece029201b2d02. No assertion, retry or release gate is weakened.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-23T10:57:25Z to 2026-11-23T11:42:27Z. Backend units: 4959, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected and zero flaky outcomes; the storefront image is unchanged by this release (only a Playwright spec changed). Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261123T105647Z. Proof inventory: Multichannel proof: 636 passed exactly once (463 standard, 173 recovery); 2 TODOs..

## Runtime scope

Every hourly native eBay run since 22 Nov 15:23 UTC failed in coverage recovery ("Native eBay recovery evidence exceeds bounded capacity") because the business repricing pushed listing operations past 1,000, so daily creation never ran on 23 Nov. Recovery now reads only create/withdraw operations and cancellations, grouped per identity, and runtime coverage/identity bounds follow eBay's 10,000-listing account cap; exceeding it still fails closed. The eBay listings admin page also takes Seller Hub's listings-left figure and books everything outside Medusa's journal as external usage on the current total budget (never raising the cap). No migration and no new schedule.

Backend diff:

apps/backend/src/admin/routes/ebay-nominations/page.tsx
apps/backend/src/api/admin/channel-sync/ebay/[id]/allowance/listings-left/__tests__/route.unit.spec.ts
apps/backend/src/api/admin/channel-sync/ebay/[id]/allowance/listings-left/route.ts
apps/backend/src/modules/channel-sync/__tests__/ebay-listing-coverage.unit.spec.ts
apps/backend/src/modules/channel-sync/ebay-listing-coverage.ts
apps/backend/src/modules/channel-sync/ebay-total-listing-budget.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:0a014e17d4794d2073fc61286771a002fd639f4bb9f88e93f61ed04cf891bf95

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:64a9fe83049cce3946521583e750c1f127569c96e9ceceae924e9c82cf6813b0 (26fcb320dae90517fd1b55657753568f489e3619); no schema change. No production order, stock or payment mutation is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-23T13:22:09.271Z; live verification pending.

## Verified completion

At 2026-11-23T13:26:05.768Z, three consecutive uncached checks confirmed the new backend and unchanged storefront exact source/digest identities, API health and /gb, all HTTP 200. This task's Cardmarket maintenance drain was resumed and confirmed not draining with zero active jobs. No marketplace write, order replay, inventory repair or payment was performed for deployment verification. No Cardmarket order was changed by deployment verification.

GitOps promotion commit: 40d967ddcf0e851b9d102e3e61e94e276b76a75d.
