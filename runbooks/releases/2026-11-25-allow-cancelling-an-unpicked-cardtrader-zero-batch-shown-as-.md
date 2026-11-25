# One-off release: Allow cancelling an unpicked CardTrader Zero batch shown as sent

Zero batch 42955381 (order #225) had every card marked not sent; CardTrader moved it to sent/done, so the unsent cancel refused and the order stayed in Pick Run forever

Owner approval: "1. Yes, using the one-off process". Exact main source e8cfd91223fd26221bcc0398a372fec2cce55d97 (archive SHA-256 cec6ed313cc9efb8d95aa9a9d5b3ffc9baa1a53ed23c35200d7c44ea2d4a6b71); commits since the live backend:

- e8cfd912 fix: allow cancelling an unpicked Zero batch CardTrader shows as sent

## Exact-source validation

Home VM validation passed from 2026-11-25T21:52:59Z to 2026-11-25T22:09:07Z (16 min) with check plan proof=true, browser=functional. Phases: install 48s, source 602s, proof-standard-a 675s, proof-standard-b 677s, proof-recovery 713s, local-stack 782s, backend-scripts 318s, proof-inventory 0s. Backend units: 4977 passed, 0 failed. Browser results: stateful 38, readonly 46, zero unexpected and zero flaky. Multichannel proof: 636 passed exactly once (270 standard-a, 193 standard-b, 173 recovery); 2 TODOs.

Not run, by the change plan: cosmetic visual checks and quick-add repeats (no storefront change). Evidence: /srv/freesplash-ci/admin/benchmark-20261125T215219Z.

## Images

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:68f3036190e82fbab075b884bd32f8d2c4abe5cd8314c64ab05572760971871a
Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:4e441766d9d94c0479ddfcb4993c0780c3b094bae847e38e2b97fa55328e261d (unchanged)

Rollback target: backend ghcr.io/craigbanach/tcg-store-backend@sha256:aad9cd071034768523b53e392e6ec1aee458a87eab2b34d14d1e5b9e1f841bab (1c7766cf63d258b0e19ccce1d519501daf55b438), storefront ghcr.io/craigbanach/tcg-store-storefront@sha256:4e441766d9d94c0479ddfcb4993c0780c3b094bae847e38e2b97fa55328e261d (7531e318056e33b96a61beccdd1a5915eec74d61). No migrations.

## Managed rollout

Worker drain acknowledged zero active jobs before submission. Every non-release manifest field is preserved; config/catalog execution stay false. Completion requires three consecutive exact-identity readiness checks and a production checkout smoke check (cart, delivery options, Stripe offered, checkout page renders; no payment is created) before the worker resumes.

Submitted 2026-11-25T22:42:09Z; live verification pending.
