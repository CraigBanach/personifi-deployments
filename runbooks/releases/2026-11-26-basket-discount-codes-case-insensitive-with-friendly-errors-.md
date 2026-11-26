# One-off release: Basket discount codes case-insensitive with friendly errors; fixed brand font URLs

Black Friday promotion BLACKFRIDAY10 starts 27 Nov and emails go out Friday morning. Discount codes were case-sensitive, an invalid code showed a minified React error, and inactive codes failed silently. Also hosts brand fonts at fixed /brand/fonts/ addresses so campaign emails keep their fonts across deploys.

Owner approval: "Owner replied '1' to: '1. Accept the retry and promote now' (26 Nov 2026)". Exact main source ffdc45ab9fe8c8979ac0d463c75ee6de955f08c4 (archive SHA-256 4d55d2e1ed9d186dc481a0bb4b683002e50128cda149ca868d9209a99b9460b4); commits since the live backend:

- ffdc45ab feat: serve brand fonts at fixed /brand/fonts/ addresses for emails
- c60e8682 fix: make basket discount codes case-insensitive with friendly errors

## Exact-source validation

Home VM validation passed from 2026-11-26T19:30:43Z to 2026-11-26T19:47:45Z (17 min) with check plan proof=true, browser=full. Phases: install 50s, source 649s, proof-standard-a 683s, proof-standard-b 708s, proof-recovery 732s, local-stack 898s, backend-scripts 322s, proof-inventory 0s. Backend units: 4977 passed, 0 failed. Browser results: stateful 38, readonly 104, quick-add-repeat 20, zero unexpected and zero flaky. Multichannel proof: 636 passed exactly once (270 standard-a, 193 standard-b, 173 recovery); 2 TODOs. Evidence: /srv/freesplash-ci/admin/benchmark-20261126T193000Z.

## Images

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:68f3036190e82fbab075b884bd32f8d2c4abe5cd8314c64ab05572760971871a (unchanged)
Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:223c61c7fc840701c6f9c99443d8fbbaa42f1f52a58b952c8dde19a9effd0f3d

Rollback target: backend ghcr.io/craigbanach/tcg-store-backend@sha256:68f3036190e82fbab075b884bd32f8d2c4abe5cd8314c64ab05572760971871a (e8cfd91223fd26221bcc0398a372fec2cce55d97), storefront ghcr.io/craigbanach/tcg-store-storefront@sha256:4e441766d9d94c0479ddfcb4993c0780c3b094bae847e38e2b97fa55328e261d (7531e318056e33b96a61beccdd1a5915eec74d61). No migrations.

## Managed rollout

Worker drain acknowledged zero active jobs before submission. Every non-release manifest field is preserved; config/catalog execution stay false. Completion requires three consecutive exact-identity readiness checks and a production checkout smoke check (cart, delivery options, Stripe offered, checkout page renders; no payment is created) before the worker resumes.

Submitted 2026-11-26T19:56:19Z; live verification pending.
