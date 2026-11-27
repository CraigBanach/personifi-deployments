# One-off release: Cardmarket: match sold split-off articles and stage waiting sales first

Two paid Cardmarket orders never became Medusa orders. Sold copies of a multi-copy Magic listing got new Cardmarket article ids that no binding knew, with no admin way to link them; this adds an owner-confirmed Match sold article action storing an inactive sale-only binding. Separately, observation staging capped at 25 oldest sales while 33 qualify with identical timestamps, so a matched sale was never re-staged; waiting-for-intake sales now go first with a deterministic tiebreak and a cap of 100.

Owner approval: "Yes, one of the CardMarket orders is still not created in Medusa (owner, 27 Nov)". Exact main source fc0caec7d8c7d73db9fa6dc55789a574bba42fec (archive SHA-256 1cb80f2ed026d29f583d7b0e850d878efc74d88a11dbdda84ff244d8ef67ffe0); commits since the live backend:

- fc0caec7 fix: stage Cardmarket sales waiting for intake first
- 47501e1f feat: let the owner match a sold Cardmarket article split off a listing
- bc8a0451 fix: hide the discount success message once the code is removed
- ffdc45ab feat: serve brand fonts at fixed /brand/fonts/ addresses for emails
- c60e8682 fix: make basket discount codes case-insensitive with friendly errors

## Exact-source validation

Home VM validation passed from 2026-11-27T11:20:45Z to 2026-11-27T11:34:20Z (14 min) with check plan proof=true, browser=functional. Phases: install 47s, source 492s, proof-standard-b 545s, proof-standard-a 545s, proof-recovery 566s, local-stack 622s, backend-scripts 275s, proof-inventory 0s. Backend units: 4983 passed, 0 failed. Browser results: stateful 38, readonly 46, zero unexpected and zero flaky. Multichannel proof: 636 passed exactly once (270 standard-a, 193 standard-b, 173 recovery); 2 TODOs.

Not run, by the change plan: cosmetic visual checks and quick-add repeats (no storefront change). Evidence: /srv/freesplash-ci/admin/benchmark-20261127T112004Z.

## Images

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:a07085ce87512ae23efdc53a0309618b7a5e0a8ab23f5ed8c7a2ef9b87caf150
Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:587b722ae8f7207fec08076a046e84864539efd2118d672b18ce66f45cf7a81b (unchanged)

Rollback target: backend ghcr.io/craigbanach/tcg-store-backend@sha256:68f3036190e82fbab075b884bd32f8d2c4abe5cd8314c64ab05572760971871a (e8cfd91223fd26221bcc0398a372fec2cce55d97), storefront ghcr.io/craigbanach/tcg-store-storefront@sha256:587b722ae8f7207fec08076a046e84864539efd2118d672b18ce66f45cf7a81b (bc8a04513f59c719adc1bc199a42c1a95ffba6ad). No migrations.

## Managed rollout

Worker drain acknowledged zero active jobs before submission. Every non-release manifest field is preserved; config/catalog execution stay false. Completion requires three consecutive exact-identity readiness checks and a production checkout smoke check (cart, delivery options, Stripe offered, checkout page renders; no payment is created) before the worker resumes.

Submitted 2026-11-27T11:38:52Z; live verification pending.
