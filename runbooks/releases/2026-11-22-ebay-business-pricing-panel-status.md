# One-off release: eBay business pricing panel status fix

On 22 November 2026 the operator asked for the eBay business pricing panel fix to be promoted through the established one-off process ("Both"). Exact main source: ed18b4ea741b90380f38c8d5847c677a45bd5bf7, one commit (ed18b4ea) on the live 7aad8c9319fee74d17c1ee6020921448d7bb07bd; this is the whole of origin/main at pin time. Archive SHA-256: bd6e1b21c2b05006f0ef82c28941a3fa05c5c68f12942c0221aa2da59a1f3ec7. No assertion, retry or release gate is weakened.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-22T14:32:54Z to 2026-11-22T15:05:58Z. Backend units: 4934, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261122T143212Z. Proof inventory: Multichannel proof: 635 passed exactly once (462 standard, 173 recovery); 2 TODOs..

## Runtime scope

After the operator saved Channels → eBay → Business pricing, the panel's status request failed: it passed the stored setting (with updated_by/updated_at) to ebayBusinessPrice, whose strict key check rejected it, so the panel kept showing "Off", the validation error and no repricing progress. The route now passes only the fee policy. Repricing itself was never affected (the listing config overlay already strips the extra keys). No migration and no schedule.

Backend diff:

apps/backend/src/api/admin/channel-sync/ebay/business-pricing/__tests__/route.unit.spec.ts
apps/backend/src/api/admin/channel-sync/ebay/business-pricing/route.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:6bcfa431995330757146cf84fc2a5b5815834ae4ab023b8a322fbb7737c75aae

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:32268f801a3108f0bfd1b7146e5e0af5f0761629c5b3d281ddbdd18756950a75 (7aad8c9319fee74d17c1ee6020921448d7bb07bd); no schema change. No production order, stock or payment mutation is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-22T15:06:24.841Z; live verification pending.
