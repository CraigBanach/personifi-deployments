# One-off release: keep SortSwift tokens apart from cards sharing their number

On 20 November 2026 the operator asked for the latest main to be promoted through the established one-off process ("Get this to main & the latest main promoted to prod using the one-off process"). Exact main source: 7aad8c9319fee74d17c1ee6020921448d7bb07bd, one commit (7aad8c93) on the live 55e6d2946ec0e3e956a43a3044d9afb343fbf583; this is the whole of origin/main at pin time. Archive SHA-256: f5279e6801d2c4430a12325a2338656f8959bc7ac0b70116c8ccf02e13a1f1f3. No assertion, retry or release gate is weakened.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-20T22:08:01Z to 2026-11-20T22:40:39Z. Backend units: 4933, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261120T220719Z. Proof inventory: Multichannel proof: 635 passed exactly once (462 standard, 173 recovery); 2 TODOs..

## Runtime scope

SortSwift files MTG tokens under the parent set code with a number the set's cards also use (ONE Cat Token #1 beside Against All Odds #1), so intake grouped them as one listing: batch MTG-0044-0052+POK-0085-0088 was refused on a laddered-price mismatch, and an equal ladder price would have added token stock to the real card. Token rows (Rarity "Token") now carry number segment t<number>-<name> in intake identity and SKU (e.g. MTG-ONE-T1-CAT-TOKEN-NORMAL-NM-EN); the CardTrader matcher reads it as the named T-numbered token and eBay shows card number T<number>. Existing listings are untouched. No migration and no schedule.

Backend diff:

apps/backend/src/modules/channel-sync/adapters/__tests__/cardtrader-mapping-matcher.unit.spec.ts
apps/backend/src/modules/channel-sync/adapters/cardtrader-mapping-matcher.ts
apps/backend/src/modules/ebay/payload.ts
apps/backend/src/scripts/__tests__/sort-swift-intake.unit.spec.ts
apps/backend/src/scripts/sort-swift-intake.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:32268f801a3108f0bfd1b7146e5e0af5f0761629c5b3d281ddbdd18756950a75

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:0a0b01a55f5e9ac9d84ba3d2b919c0bd268f96bc52f982c1d3e623c71813fdd4 (55e6d2946ec0e3e956a43a3044d9afb343fbf583); no schema change. No production order, stock or payment mutation is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-20T22:41:36.179Z; live verification pending.
