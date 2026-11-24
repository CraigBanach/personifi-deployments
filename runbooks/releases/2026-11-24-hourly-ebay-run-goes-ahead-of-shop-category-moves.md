# One-off release: Hourly eBay run goes ahead of shop-category moves

Whole-catalogue shop-category moves held the eBay account lock continuously, so every hourly run (listing creation and sweeps) since 09:00 was skipped and 145 of today's listings waited. Bulk price-sync batches now stop starting at :45 and the hourly run waits up to 25 minutes for the lock. Validation: one storefront stateful retry (checkout-states 1440px fit test) passed on retry; owner reviewed and accepted it; no storefront change in this release.

Owner approval: "PRomote it, then let's dig into the test (owner, 24 Nov)". Exact main source 1c6b0ef9b1937f0fbe27038e5797cfd1b5e0c91f (archive SHA-256 7aadaade7ab392c5b51ebe96b518a21647422cb21c6789dc7894476a25433556); commits since the live backend:

- 1c6b0ef9 fix: let the hourly eBay run go ahead of shop-category moves and repricing

## Exact-source validation

Home VM validation passed from 2026-11-24T12:19:02Z to 2026-11-24T12:34:14Z (15 min) with check plan proof=true, browser=functional. Phases: install 49s, source 530s, proof-standard-a 629s, proof-standard-b 629s, proof-recovery 666s, local-stack 830s, backend-scripts 331s, proof-inventory 0s. Backend units: 4972 passed, 0 failed. Browser results: stateful 37, readonly 46, zero unexpected and zero flaky. Multichannel proof: 636 passed exactly once (270 standard-a, 193 standard-b, 173 recovery); 2 TODOs.

Not run, by the change plan: cosmetic visual checks and quick-add repeats (no storefront change). Evidence: /srv/freesplash-ci/admin/benchmark-20261124T121823Z.

## Images

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:ecbbf87c18faea5a19bd0e8245ba1609d6d5a005abcbeeee44dba7f9ffbd3466
Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (unchanged)

Rollback target: backend ghcr.io/craigbanach/tcg-store-backend@sha256:a599889b3634f8352b985cf8c67d54c22c8838d7cbd251013674695b9b7e97a2 (287be90b7b8913cd3781c0918d2c7a5ceac082d9), storefront ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). No migrations.

## Managed rollout

Worker drain acknowledged zero active jobs before submission. Every non-release manifest field is preserved; config/catalog execution stay false. Completion requires three consecutive exact-identity readiness checks and a production checkout smoke check (cart, delivery options, Stripe offered, checkout page renders; no payment is created) before the worker resumes.

Submitted 2026-11-24T13:11:21Z; live verification pending.
