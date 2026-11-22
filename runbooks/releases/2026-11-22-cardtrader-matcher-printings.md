# One-off release: CardTrader auto-mapping matcher fix

On 22 November 2026 the operator asked for the items missing from marketplaces to be fixed. Operator approval to promote this release: operator, 22 November 2026 ~21:05Z, in reply to "promote 3c4c1220 once validation passes?": "I don't know, just work with the other session to get everything live". Exact main source: 3c4c122045bd1d4b0dd1074351f8b6239a834c6e, one commit (3c4c1220) on the live d6a5a43bd669b3a8bb9cc544c60604f4c424923e; later main commits (79b601df, storefront test only) are excluded. Archive SHA-256: 195189fb008b69122d4ab6fdea3e6f76e70daa01d1ea77acac89f7580ecd2851. No assertion, retry or release gate is weakened.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-22T20:26:44Z to 2026-11-22T20:59:13Z. Backend units: 4945, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261122T202605Z. Proof inventory: Multichannel proof: 635 passed exactly once (462 standard, 173 recovery); 2 TODOs..

## Runtime scope

CardTrader automatic mapping skipped 17 in-stock cards: 13 stamped 30th Celebration Pikachus (the version "1/30 Stamp | Holo Rare 023/128" was read as set size 30; the last n/m is now used), two 30th Celebration Mega Evolution Energies (the alias set's own card shares the number; the "MEE 010" printing is now taken when the numbered card is not named like ours), and two cards whose CardTrader names add a trainer or level suffix. Matching only; no listing write path, migration or schedule change. CardNexus and Cardmarket derive their ids from these mappings.

Backend diff:

apps/backend/src/modules/channel-sync/adapters/__tests__/cardtrader-mapping-matcher.unit.spec.ts
apps/backend/src/modules/channel-sync/adapters/cardtrader-mapping-matcher.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:6bd7b4de0636ad4f81d698495165d10236ab8b53313a8af15d7354ea2c4f4d36

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:37c77e119b864af286c726098b624981af3b91ecb179f38e8125ff2ae5b45e42 (d6a5a43bd669b3a8bb9cc544c60604f4c424923e); no schema change. No production order, stock or payment mutation is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-22T21:42:35.385Z; live verification pending.
