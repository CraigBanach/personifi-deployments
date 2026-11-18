# One-off release: post linked Cardmarket orders in one parcel; untracked parcel match fix

On 18 November 2026 the operator requested this change be deployed through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is c1bfc2e7778701e337642b7bdc25507b618baeaa (two commits on top of the live 675687e3a3ce9ba58c09dc5118fd70a3a9ab5ef0: 92afde94 listing-intake barcodes/bundle counts from another session, included at the operator's request, and c1bfc2e7), archive SHA-256 17240579b368de3b3c87927938f6a24b8f443e9c45af24bfebe9e8d15b68238a.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-18T14:31:29Z to 2026-11-18T15:00:22Z. Backend units: 4883, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261118T143050Z, local ebay-refund-release-20261118. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

eBay-only (no Medusa stock) lines now ship after a partial refund: the marketplace-line sweep reads the order through a pre-refund view that must still match the frozen import fingerprint exactly (eBay #192, postage refunded). Cardmarket label recording refuses up front while an order edit is open, logs real workflow error messages, and the order page offers Retry label recording for an undespatched parcel parked by either cause (#205). Listing intake (92afde94) captures validated barcodes and bundle counts. No order is changed by deployment. Backend diff:

apps/backend/src/admin/components/order/order-click-and-drop.tsx
apps/backend/src/admin/widgets/product-sealed-details.tsx
apps/backend/src/api/admin/products/[id]/sealed-details/__tests__/route.unit.spec.ts
apps/backend/src/api/admin/products/[id]/sealed-details/route.ts
apps/backend/src/data/listing-intake.template.csv
apps/backend/src/lib/__tests__/catalog-identifiers.unit.spec.ts
apps/backend/src/lib/__tests__/order-dispatch-guidance.unit.spec.ts
apps/backend/src/lib/__tests__/sealed-product.unit.spec.ts
apps/backend/src/lib/catalog-identifiers.ts
apps/backend/src/lib/click-and-drop/sync.ts
apps/backend/src/lib/order-dispatch-guidance-model.ts
apps/backend/src/lib/order-dispatch-guidance.ts
apps/backend/src/lib/sealed-product-shared.ts
apps/backend/src/lib/sealed-product.ts
apps/backend/src/modules/channel-sync/__tests__/attachment-label-fulfillment.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/ebay-shipment.unit.spec.ts
apps/backend/src/modules/channel-sync/adapters/ebay-marketplace-line-sweep.ts
apps/backend/src/modules/channel-sync/adapters/ebay-shipment.ts
apps/backend/src/modules/channel-sync/adapters/ebay-source.ts
apps/backend/src/modules/channel-sync/attachment-label-fulfillment.ts
apps/backend/src/scripts/__tests__/listing-intake.unit.spec.ts
apps/backend/src/scripts/listing-intake.ts
apps/backend/src/scripts/sync-catalog.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 and exercises the pre-refund view and sweep wiring, label-retry guidance and admin button, and the open-edit refusal plus the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:7d5f371fa886668644f16e63a635356986bd0ccc929fc1bb32a78d4b17b66233

Rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:177542930d97a023f8c3c88cc9bc961edabf6568f67f6d8e715efc1fdf78dcbe (675687e3a3ce9ba58c09dc5118fd70a3a9ab5ef0). No schema change, order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-18T15:01:18.593Z; live verification pending.

## Verified completion

At 2026-11-18T15:04:12.494Z, three consecutive uncached checks confirmed the new backend and unchanged storefront exact source/digest identities, API health and /gb, all HTTP 200. This task's Cardmarket maintenance drain was resumed and confirmed not draining with zero active jobs. No marketplace write, order replay, inventory repair or payment was performed for deployment verification. No Cardmarket order was changed by deployment verification.

GitOps promotion commit: 8c8a62c828534a6087e1ca2ed5249b0f174c755f.
