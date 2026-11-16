# One-off release: Cardmarket health alerts and current main

On 16 November 2026 the operator requested deployment of main through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is d1303e34bd55051bf044e84bc661aeb9ebc335ee, with archive SHA-256 b81457e0198743c72de0c8d934c3fe53a13f92974264fd2469da03475d15a677. Unrelated dirty files and the separate home-server automatic-login experiment are excluded.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-16T19:29:40Z to 2026-11-16T19:58:07Z: frozen installation, source checks, synthetic application/SQL/email/marketing/browser tests, both stock-safety proof partitions and exhaustive proof inventory. Backend units: 4683, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261116T192901Z, local cardmarket-health-release-20261116-r4. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs.. Prior evidence was not accepted: 42882010 had a nullable test-fixture compiler error, fa720195 had three stale selector assertions, and bac94eef passed all six phases but required one browser retry. Fixture/assertion-only fixes preserved coverage, and the updated source additionally contains the operator-requested split-sale recovery and intake alert. Only this exact SHA's full clean evidence is accepted; no assertion timeout, retry policy or coverage gate was changed.

## Runtime scope

Cardmarket gains an independent five-minute read-only watchdog for unhealthy sessions, offline/missing workers, queued work over thirty minutes, unconfirmed posted parcels over thirty minutes and paid sales still missing native orders after thirty minutes. Alerts use the admin feed and existing audited SMTP, deduplicated per reason/connection/recipient/UTC day. Failed or uncertain email deliveries remain under the SMTP retry system. Email defaults to the existing transactional sender mailbox; no secret or runtime setting was changed. No automatic marketplace login is installed.

The operator separately requested repair and prevention of split sale article IDs. Intake now retains inactive sale-only aliases for one narrowly proven case: a unique previously listed English NM fixed-finish Pokemon holofoil, exact Cardmarket product/grade/language and listing receipt, and complete pre/post censuses showing only that source article with the exact sold-quantity decrease. Signed/altered/graded/editable-finish, ambiguous or missing evidence, historic exclusions and admitted commitments fail closed. Original active stock bindings remain intact and ordinary fenced stock reservation/order creation remain authoritative. No schema migration is added. Existing paid sale 1314729361 was separately repaired with previewed exact aliases and normal intake, becoming order 199; that completed operational action is not replayed by deployment. See source docs/cardmarket-split-sale-recovery.md for evidence and explicit limits.

Current main also includes whole-order pick eligibility/missing-card fixes and the storefront basket quantity-increase fix since the respective live images. Reviewed backend diff:

apps/backend/src/api/admin/orders/[id]/stock-locations/pick/route.ts
apps/backend/src/api/admin/orders/[id]/stock-locations/route.ts
apps/backend/src/api/admin/pick-runs/confirm/route.ts
apps/backend/src/api/admin/pick-runs/route.ts
apps/backend/src/jobs/cardmarket-health.ts
apps/backend/src/lib/__tests__/pick-run-eligibility.unit.spec.ts
apps/backend/src/lib/click-and-drop/__tests__/readiness.unit.spec.ts
apps/backend/src/lib/click-and-drop/sync.ts
apps/backend/src/lib/pick-run-eligibility.ts
apps/backend/src/modules/channel-sync/__tests__/cardmarket-health.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/cardmarket-sale-split.unit.spec.ts
apps/backend/src/modules/channel-sync/cardmarket-health.ts
apps/backend/src/modules/channel-sync/cardmarket-order-observation.ts
apps/backend/src/modules/channel-sync/cardmarket-sale-split.ts

Storefront diff:

apps/storefront/cart-quantity.test.js
apps/storefront/src/modules/cart/components/item/index.tsx
apps/storefront/tests/e2e/purchase-surfaces.spec.ts

Both images use the same validated archive. Backend packaged proofs run network-disabled/read-only as UID 1000 and exercise pick safety and health alert/dedup/scheduling. Storefront packaged proof verifies Linux amd64/non-root/read-only runtime identity and unchanged public Stripe/PostHog inputs.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:b40d852e8276e48ce25cf22cbec30a422ecfd4b472cee51d449a43c1d49362a8

Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:5b3d28f31ae9b4d2ed82bc2b40c226648bf0283abb9ba6ed74325d436c26d4f7

Previous backend rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:959b768d51a5238a0c016b2c1178bc10b2c220fd9751304ac94385d6324d0ec9 (56b79d8fed9ad5eb9e8ba4e1386bd79e26a6c314). Previous storefront rollback target: ghcr.io/craigbanach/tcg-store-storefront@sha256:0f8e8fbd1d84103d62de62e7c33cd67055dc224d1a4c7b0d4f8f32ef83bcc5ec (182cd9cc38ef7ce5f419021779aa72a404e53731). No schema rollback, order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Managed migration and rollout gates remain active. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce. Publishing is not deployment success.

Submitted 2026-11-16T19:59:14.940Z; live verification pending.
