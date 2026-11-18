# One-off release: tracked eBay postage from a set price

On 18 November 2026 the operator requested this change be deployed through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is bb451d8c9ba5e7d5379fb28e2aed9afd11938908 (one backend commit on top of the live 9efdd5178cf19f3332daf00d9f7b1a335d909dd7), archive SHA-256 61655ab2e693e57017733fd0f958c94afeed5474bb1caacd1afe99d55524fea9.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-18T10:24:04Z to 2026-11-18T10:52:23Z. Backend units: 4826, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261118T102324Z, local ebay-tracked-release-20261118. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

After an untracked 2nd Class £90 eBay sale was not received, delivery policies gain admin fields: a tracked-from buyer price and a tracked eBay fulfillment policy. eBay offers at or above it use the tracked policy, in the manual publish route and the native listing sync (rules read from delivery_policy when the reviewed lifecycle config loads); existing listings switch through normal offer drift. Nothing changes until the operator sets a rule. No order is changed by deployment. Backend diff:

apps/backend/src/admin/routes/delivery-policies/page.tsx
apps/backend/src/api/admin/delivery-policies/route.ts
apps/backend/src/api/admin/ebay/publish/route.ts
apps/backend/src/modules/channel-sync/adapters/ebay-lifecycle-config.ts
apps/backend/src/modules/ebay/__tests__/payload.unit.spec.ts
apps/backend/src/modules/ebay/__tests__/tracked-delivery-policies.unit.spec.ts
apps/backend/src/modules/ebay/migrations/Migration20261118110000.ts
apps/backend/src/modules/ebay/models/delivery-policy.ts
apps/backend/src/modules/ebay/payload.ts
apps/backend/src/modules/ebay/tracked-delivery-policies.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 and exercises the tracked-price threshold, loader injection, migration and admin fields plus the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:d4a2fb1cc7e858f222a92a2311a7618e90b15821078378ffaa464024a1205b23

Rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:fabba2d68a35c2432af8f07285e7663bbffd19bc5f5dd95468ba38f2a6364fea (9efdd5178cf19f3332daf00d9f7b1a335d909dd7). Schema change: additive nullable delivery_policy columns (Migration20261118110000, ebay module) run by the managed migrate job; rollback-compatible. No order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-18T10:53:03.472Z; live verification pending.

## Verified completion

At 2026-11-18T10:55:49.544Z, three consecutive uncached checks confirmed the new backend and unchanged storefront exact source/digest identities, API health and /gb, all HTTP 200. This task's Cardmarket maintenance drain was resumed and confirmed not draining with zero active jobs. No marketplace write, order replay, inventory repair or payment was performed for deployment verification. No Cardmarket order was changed by deployment verification.

GitOps promotion commit: aa45878960fde850fdb708b4dbe0dd14c7c36f70.
