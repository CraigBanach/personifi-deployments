# One-off release: finish a stopped marketplace import from its order page

On 19 November 2026 the operator chose to finish stuck eBay order #214 properly ("Finish it properly") through the established one-off process. Exact main source: 55e6d2946ec0e3e956a43a3044d9afb343fbf583, one commit (55e6d294) on the live 809c0a8cc7767215d0712779ee92f55449caf792; this is the whole of origin/main at pin time. Archive SHA-256: 429b505f307f8dfa88ad7a6c4b80879ea38fa78abbbe2ba69a34099ad07e39f8. No assertion, retry or release gate is weakened.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-19T16:18:57Z to 2026-11-19T16:51:27Z. Backend units: 4931, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261119T161818Z. Proof inventory: Multichannel proof: 635 passed exactly once (462 standard, 173 recovery); 2 TODOs..

## Runtime scope

An import that stopped after its native order was created and linked (plan uncertain, reason native_import_incomplete; usually no stock to reserve) gains an order-page panel and an operator-only "Finish import" action (GET/POST /admin/orders/:id/marketplace-import-finish). Under the native order lock it re-verifies the order against its frozen plan (lines and financials), reserves the mapped demand only when no reservation exists, completes the import and queues the marketplace payment event; any failure returns the import to uncertain review. No migration and no schedule; nothing runs without an operator click.

Backend diff:

apps/backend/integration-tests/http/multichannel-consistency.spec.ts
apps/backend/src/admin/components/order/order-marketplace-finish-import.tsx
apps/backend/src/admin/widgets/order-marketplace.tsx
apps/backend/src/api/admin/orders/[id]/marketplace-import-finish/route.ts
apps/backend/src/modules/channel-sync/__tests__/finish-uncertain-import.unit.spec.ts
apps/backend/src/modules/channel-sync/finish-uncertain-import.ts
apps/backend/src/modules/channel-sync/service.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:0a0b01a55f5e9ac9d84ba3d2b919c0bd268f96bc52f982c1d3e623c71813fdd4

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:58abfdb1d45b2e1e36b48bd71df8816377b8d9cfa84879eb540bf7dfde738408 (809c0a8cc7767215d0712779ee92f55449caf792); no schema change. No production order, stock or payment mutation is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-19T17:31:24.010Z; live verification pending.
