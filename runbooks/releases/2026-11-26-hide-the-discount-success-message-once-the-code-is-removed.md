# One-off release: Hide the discount success message once the code is removed

Follow-up to ffdc45ab found in live acceptance testing: after removing a discount code the 'applied' message stayed visible. Cosmetic fix before Black Friday emails go out.

Owner approval: "Owner: 'Get this promoted' (26 Nov 2026)". Exact main source bc8a04513f59c719adc1bc199a42c1a95ffba6ad (archive SHA-256 5864253aca82a17ccb12ec6714c2d6cbeddb3854a09e5698948d995d1a6d7806); commits since the live backend:

- bc8a0451 fix: hide the discount success message once the code is removed
- ffdc45ab feat: serve brand fonts at fixed /brand/fonts/ addresses for emails
- c60e8682 fix: make basket discount codes case-insensitive with friendly errors

## Exact-source validation

Home VM validation passed from 2026-11-26T20:07:58Z to 2026-11-26T20:20:13Z (12 min) with check plan proof=false, browser=full. Phases: install 51s, source 386s, local-stack 610s, backend-scripts 297s. Backend units: 4977 passed, 0 failed. Browser results: stateful 38, readonly 105, quick-add-repeat 20, zero unexpected and zero flaky. Not required by the change plan

Not run, by the change plan: multichannel stock proof (no backend runtime change). Evidence: /srv/freesplash-ci/admin/benchmark-20261126T200713Z.

## Images

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:68f3036190e82fbab075b884bd32f8d2c4abe5cd8314c64ab05572760971871a (unchanged)
Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:587b722ae8f7207fec08076a046e84864539efd2118d672b18ce66f45cf7a81b

Rollback target: backend ghcr.io/craigbanach/tcg-store-backend@sha256:68f3036190e82fbab075b884bd32f8d2c4abe5cd8314c64ab05572760971871a (e8cfd91223fd26221bcc0398a372fec2cce55d97), storefront ghcr.io/craigbanach/tcg-store-storefront@sha256:223c61c7fc840701c6f9c99443d8fbbaa42f1f52a58b952c8dde19a9effd0f3d (ffdc45ab9fe8c8979ac0d463c75ee6de955f08c4). No migrations.

## Managed rollout

Worker drain acknowledged zero active jobs before submission. Every non-release manifest field is preserved; config/catalog execution stay false. Completion requires three consecutive exact-identity readiness checks and a production checkout smoke check (cart, delivery options, Stripe offered, checkout page renders; no payment is created) before the worker resumes.

Submitted 2026-11-26T20:20:46Z; live verification pending.
