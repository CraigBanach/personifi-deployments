# One-off release: Cardmarket untracked parcel references

On 17 November 2026 the operator requested this fix be deployed through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is eabd89206e11b61e0829f5dcdadb132faa6cc5af (one backend commit on top of the live 70434c0152268bb26640ddcc78bbf61bea51f554), archive SHA-256 3e2914b652066ac7b6a3f4208b17b442d0eefe7a344fbfee10de562e90c10415.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-17T17:41:57Z to 2026-11-17T18:10:03Z. Backend units: 4819, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261117T174119Z, local cm-untracked-tracking-release-20261117. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

Click & Drop gave untracked Cardmarket parcels an 11-digit reference padded with spaces. It was recorded as Cardmarket tracking; the worker's trimmed readback never matched, tracking upload went to review and the Sent update (which waits for confirmed tracking) never ran (orders 1313611912 and 1314729361; the latter raised dispatch_stalled). References are now trimmed, and for buyers who did not pay for tracking only a UPU S10 tracking number is given to Cardmarket; otherwise Sent proceeds without tracking. Tracked orders are unchanged apart from trimming. The existing stuck order is not altered by deployment. Backend diff:

apps/backend/src/lib/click-and-drop/__tests__/cardnexus-despatch.unit.spec.ts
apps/backend/src/lib/click-and-drop/sync.ts
apps/backend/src/modules/channel-sync/__tests__/cardmarket-tracking-reference.unit.spec.ts
apps/backend/src/modules/channel-sync/cardmarket-dispatch.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 and exercises the new reference rule and its use in Click & Drop sync plus the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:ace4476238dc91a517c5930cd165dd4b6b8b9452ea8931cabf5fb9be06fd1d68

Rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:794912f1b853cc46b13d146428015ba715d843c57a07192227aadd061db0b052 (70434c0152268bb26640ddcc78bbf61bea51f554). No schema change, order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-17T18:10:52.567Z; live verification pending.

## Verified completion

At 2026-11-17T18:14:42.348Z, three consecutive uncached checks confirmed the new backend and unchanged storefront exact source/digest identities, API health and /gb, all HTTP 200. This task's Cardmarket maintenance drain was resumed and confirmed not draining with zero active jobs. No marketplace write, order replay, inventory repair or payment was performed for deployment verification. No Cardmarket order was changed by deployment verification.

GitOps promotion commit: db0273f1257294d29a44a72dad82658d0cf77520.
