# One-off release: CardTrader listings deleted after selling out

On 22 November 2026 the operator asked for the three failing CardTrader listings to be fixed. Operator approval to promote this release: operator, 22 November 2026 ~22:10Z: "Go ahead with the CardTrader fix" (after earlier, ~21:05Z: "just work with the other session to get everything live"). Exact main source: 13a1c92fd4a9c3425099175e01e199d4533f0483, one commit (13a1c92f) on the live 7e12d21f3559572d5036dd1dbd6fd6eb607450fe. Archive SHA-256: b6f0510d3a130e15be3c66c267008340d5b4dfefe2707ffad89dc42f3cc951c6. No assertion, retry or release gate is weakened.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-22T22:24:16Z to 2026-11-22T22:57:19Z. Backend units: 4946, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261122T222337Z. Proof inventory: Multichannel proof: 636 passed exactly once (463 standard, 173 recovery); 2 TODOs..

## Runtime scope

CardTrader deletes a product once a sale takes it to 0. Three restocked cards (Pikachu 032/128 30th Celebration, Forest 271 and Swamp 269 All Will Be One) failed every run with "Listing action differs from retained identity/state" because their bindings still said live with the deleted IDs; 41 more sold-out cards were in the same state. A live binding whose ID and marker are both missing from a complete, account-verified export, with no unresolved operation and nothing written for 10 minutes, now settles absent so a restock creates a fresh listing.

Backend diff:

apps/backend/integration-tests/http/multichannel-consistency.spec.ts
apps/backend/src/modules/channel-sync/adapters/cardtrader-listing-sync.ts
apps/backend/src/modules/channel-sync/service.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:ac4eae749fbded4e4e897930d450a95444652f13e428bdedfff818794a00e1de

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:adeebbb1ed6615cfb23dd37d72bf9b2d3536c5159b1bd20e362291e3edd79bf0 (7e12d21f3559572d5036dd1dbd6fd6eb607450fe); no schema change. No production order, stock or payment mutation is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-22T22:59:21.025Z; live verification pending.

## Verified completion

At 2026-11-22T23:02:55.815Z, three consecutive uncached checks confirmed the new backend and unchanged storefront exact source/digest identities, API health and /gb, all HTTP 200. This task's Cardmarket maintenance drain was resumed and confirmed not draining with zero active jobs. No marketplace write, order replay, inventory repair or payment was performed for deployment verification. No Cardmarket order was changed by deployment verification.

GitOps promotion commit: 0120fe98c42f24e34f05394139da23ff0ce45fd8.
