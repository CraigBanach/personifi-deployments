# One-off release: a later confirmed eBay stock write resolves an earlier unknown one

On 22 November 2026 the operator asked for current main to ship through the established one-off process ("If your fix has everything, just send it"). Exact main source: 7e12d21f3559572d5036dd1dbd6fd6eb607450fe, two commits (79b601df storefront sticky-actions test no longer depends on page length (test-only); 7e12d21f a later acknowledged/observed eBay stock attempt supersedes an earlier uncertain one) on the live 3c4c122045bd1d4b0dd1074351f8b6239a834c6e; this is the whole of origin/main at pin time. Archive SHA-256: 0a3d211e2d0034a8cd52dbe5e9d6fd6ac78de04f76a03b891eabddfaf081ce53. No assertion, retry or release gate is weakened.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-22T21:44:51Z to 2026-11-22T22:17:28Z. Backend units: 4946, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected and zero flaky outcomes; the storefront image is unchanged by this release (only a Playwright spec changed). Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261122T214411Z. Proof inventory: Multichannel proof: 635 passed exactly once (462 standard, 173 recovery); 2 TODOs..

## Runtime scope

eBay journal admission and listing reconciliation no longer treat an uncertain stock attempt as blocking once a later generation's stock attempt was acknowledged or observed, so listings stuck behind old unknown stock writes accept price and stock updates again. No migration and no new schedule.

Backend diff:

apps/backend/src/modules/channel-sync/__tests__/ebay-abandoned-updates.unit.spec.ts
apps/backend/src/modules/channel-sync/ebay-listing-journal.ts
apps/backend/src/modules/channel-sync/ebay-listing-reconciliation.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:adeebbb1ed6615cfb23dd37d72bf9b2d3536c5159b1bd20e362291e3edd79bf0

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:6bd7b4de0636ad4f81d698495165d10236ab8b53313a8af15d7354ea2c4f4d36 (3c4c122045bd1d4b0dd1074351f8b6239a834c6e); no schema change. No production order, stock or payment mutation is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-22T22:18:27.143Z; live verification pending.
