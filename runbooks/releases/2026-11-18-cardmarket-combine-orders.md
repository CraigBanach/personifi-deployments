# One-off release: combine a Cardmarket order with another order

On 18 November 2026 the operator requested this change be deployed through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is 9efdd5178cf19f3332daf00d9f7b1a335d909dd7 (one backend commit on top of the live eabd89206e11b61e0829f5dcdadb132faa6cc5af), archive SHA-256 53f08f24af8ce29b887de493e675a7e975163356e190cda1767d4f20dbbbb921.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-18T09:53:41Z to 2026-11-18T10:23:11Z. Backend units: 4821, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261118T095302Z, local cm-bundle-release-20261118. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

Adds an admin action on unpicked, paid Cardmarket orders that cancels the Medusa order (no email) and releases its reservations, so the buyer's cards can be combined into another order's postage. It retains an operator-authorised cancelled settlement and is refused if Cardmarket shows the sale sent, cancelled, disputed or changed, or if it is picked or has Click & Drop postage. Cardmarket is not written; the operator marks the sale Sent there. No order is changed by deployment. Backend diff:

apps/backend/src/admin/components/order/order-attachment-settlement.tsx
apps/backend/src/api/admin/orders/[id]/attachment-bundle/route.ts
apps/backend/src/modules/channel-sync/__tests__/cardmarket-settlement.unit.spec.ts
apps/backend/src/modules/channel-sync/adapters/cardmarket-attachment-authority.ts
apps/backend/src/modules/channel-sync/attachment-settlement-sweep.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 and exercises the new combine authority, route and admin action plus the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:fabba2d68a35c2432af8f07285e7663bbffd19bc5f5dd95468ba38f2a6364fea

Rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:ace4476238dc91a517c5930cd165dd4b6b8b9452ea8931cabf5fb9be06fd1d68 (eabd89206e11b61e0829f5dcdadb132faa6cc5af). No schema change, order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-18T10:25:35.143Z; live verification pending.
