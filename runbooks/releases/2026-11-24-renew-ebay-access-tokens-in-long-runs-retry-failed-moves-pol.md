# One-off release: Renew eBay access tokens in long runs; retry failed moves; poll during moves

Daily eBay creation runs outlived their 2-hour access token at ~16:00 on 23 and 24 Nov, blocking the rest of the day's picks; transient eBay read failures closed shop-category moves for good; long move drains stopped order polling for up to 84 minutes.

Owner approval: "Yes (owner, 24 Nov, to: release it now through the one-off process and re-queue the 30 moves)". Exact main source 1c7766cf63d258b0e19ccce1d519501daf55b438 (archive SHA-256 02d96f252ef3b12ec71cff81f37bcb373301f803c346a653dcf1509fa8c3e4d7); commits since the live backend:

- 1c7766cf fix: renew eBay access tokens in long runs and keep polling during moves

## Exact-source validation

Home VM validation passed from 2026-11-24T18:50:25Z to 2026-11-24T19:06:37Z (16 min) with check plan proof=true, browser=functional. Phases: install 65s, source 593s, proof-standard-a 648s, proof-standard-b 660s, proof-recovery 705s, local-stack 773s, backend-scripts 313s, proof-inventory 0s. Backend units: 4976 passed, 0 failed. Browser results: stateful 38, readonly 46, zero unexpected and zero flaky. Multichannel proof: 636 passed exactly once (270 standard-a, 193 standard-b, 173 recovery); 2 TODOs.

Not run, by the change plan: cosmetic visual checks and quick-add repeats (no storefront change). Evidence: /srv/freesplash-ci/admin/benchmark-20261124T184943Z.

## Images

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:aad9cd071034768523b53e392e6ec1aee458a87eab2b34d14d1e5b9e1f841bab
Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:4e441766d9d94c0479ddfcb4993c0780c3b094bae847e38e2b97fa55328e261d (unchanged)

Rollback target: backend ghcr.io/craigbanach/tcg-store-backend@sha256:062bb3771d4631663ff7cca9582694027a9c3c753084318d0ca2d249ba539f07 (7531e318056e33b96a61beccdd1a5915eec74d61), storefront ghcr.io/craigbanach/tcg-store-storefront@sha256:4e441766d9d94c0479ddfcb4993c0780c3b094bae847e38e2b97fa55328e261d (7531e318056e33b96a61beccdd1a5915eec74d61). No migrations.

## Managed rollout

Worker drain acknowledged zero active jobs before submission. Every non-release manifest field is preserved; config/catalog execution stay false. Completion requires three consecutive exact-identity readiness checks and a production checkout smoke check (cart, delivery options, Stripe offered, checkout page renders; no payment is created) before the worker resumes.

Submitted 2026-11-24T19:07:58Z; live verification pending.
