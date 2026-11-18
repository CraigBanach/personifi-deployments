# One-off release: stop SortSwift intake and product views starving the DB pool

On 18 November 2026 the operator requested this change be deployed through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is a908a11e5ac43a0cc61d5d3fd4ce292784c41b0d (two commits on top of the live c1bfc2e7778701e337642b7bdc25507b618baeaa: 8c500514 and a908a11e; later main commits from other sessions are deliberately excluded), archive SHA-256 cfed3ff458d565c7aab10a1fb269927f3ac463c2c2e5c331fed219c65a715162.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-18T17:07:29Z to 2026-11-18T17:36:38Z. Backend units: 4887, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261118T170649Z, local intake-lock-release-20261118. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

On 18 Nov a 99-card SortSwift batch held the shared stock-locations writer lock for ~30 s per card, because each card read the whole catalogue. Admin product views queued on the same lock and exhausted the 10-connection pool (60 s connection-acquire timeouts). Intake now looks up the single product by identity; brand-new cards are created without the writer lock (restocks keep it); catalogue sync reads only the handles it syncs; GET product stock-locations no longer takes the lock; writer-lock waits are bounded by lock_timeout 60s. No order is changed by deployment. Backend diff:

apps/backend/src/api/admin/products/[id]/stock-locations/route.ts
apps/backend/src/lib/__tests__/sort-swift-intake-channels.unit.spec.ts
apps/backend/src/lib/__tests__/sort-swift-restock.unit.spec.ts
apps/backend/src/lib/sort-swift-intake-batches.ts
apps/backend/src/modules/channel-sync/service.ts
apps/backend/src/scripts/sync-catalog.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:674b363d33e0e962f14bafd28882b08f1d0b74d173bb2aabff510e464dab50b2

Rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:7d5f371fa886668644f16e63a635356986bd0ccc929fc1bb32a78d4b17b66233 (c1bfc2e7778701e337642b7bdc25507b618baeaa). No schema change, order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-18T17:38:53.192Z; live verification pending.
