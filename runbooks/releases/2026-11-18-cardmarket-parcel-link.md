# One-off release: post linked Cardmarket orders in one parcel; untracked parcel match fix

On 18 November 2026 the operator requested this change be deployed through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is 675687e3a3ce9ba58c09dc5118fd70a3a9ab5ef0 (one backend commit on top of the live bb451d8c9ba5e7d5379fb28e2aed9afd11938908), archive SHA-256 d6a2cb5a6317963ace1372ab0f3829ac444255b76d2f1f0c9ead9355f0f5e9da.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-18T11:15:59Z to 2026-11-18T11:44:38Z. Backend units: 4839, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261118T111520Z, local cm-parcel-link-release-20261118. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

A buyer's open Cardmarket order can be linked to another of their open Cardmarket orders (same connection and address, unsettled, no postage prepared). The linked order is never sent to Click & Drop; the primary waits until all travelling orders are picked and carries their cards. On despatch each linked order gets the same parcel dispatch evidence, protected Medusa shipment and Sent queue; the settlement sweep recognises the primary's parcel. Also fixes untracked Cardmarket parcels since eabd8920: a null dispatch tracking now matches the parcel (previously IS NOT DISTINCT FROM refused native shipment); otherwise trimmed references must match. Checked against real Postgres. No order is changed by deployment. Backend diff:

apps/backend/src/admin/components/order/order-attachment-settlement.tsx
apps/backend/src/admin/components/order/order-cardmarket-parcel-link.tsx
apps/backend/src/admin/widgets/order-marketplace.tsx
apps/backend/src/api/admin/orders/[id]/cardmarket-parcel-link/route.ts
apps/backend/src/lib/click-and-drop/__tests__/cardmarket-parcel-link.unit.spec.ts
apps/backend/src/lib/click-and-drop/__tests__/marketplace-postgres.unit.spec.ts
apps/backend/src/lib/click-and-drop/cardmarket.ts
apps/backend/src/lib/click-and-drop/sync.ts
apps/backend/src/modules/channel-sync/adapters/cardmarket-attachment-authority.ts
apps/backend/src/modules/channel-sync/cardmarket-parcel-link.ts
apps/backend/src/modules/channel-sync/migrations/Migration20261118120000.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 and exercises the parcel-link module, route, migration, admin panel, despatch and parcel-match SQL plus the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:177542930d97a023f8c3c88cc9bc961edabf6568f67f6d8e715efc1fdf78dcbe

Rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:d4a2fb1cc7e858f222a92a2311a7618e90b15821078378ffaa464024a1205b23 (bb451d8c9ba5e7d5379fb28e2aed9afd11938908). Schema change: new table channel_cardmarket_parcel_link (Migration20261118120000, channel-sync module) run by the managed migrate job; rollback-compatible. No order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-18T12:35:09.193Z; live verification pending.

## Verified completion

At 2026-11-18T12:39:06.142Z, three consecutive uncached checks confirmed the new backend and unchanged storefront exact source/digest identities, API health and /gb, all HTTP 200. This task's Cardmarket maintenance drain was resumed and confirmed not draining with zero active jobs. No marketplace write, order replay, inventory repair or payment was performed for deployment verification. No Cardmarket order was changed by deployment verification.

GitOps promotion commit: 4574c621db80f6673487b6598e825d55f450bab1.
