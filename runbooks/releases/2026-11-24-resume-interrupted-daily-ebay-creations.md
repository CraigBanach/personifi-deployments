# One-off release: Resume interrupted daily eBay creations

The 00:29 release restarted the backend mid-run and the remaining 145 of today's 166 eBay creations were never resumed; later runs now finish the admitted pick.

Owner approval: "Yes (owner, 24 Nov, approving the fix to resume interrupted daily eBay creations)". Exact main source 287be90b7b8913cd3781c0918d2c7a5ceac082d9 (archive SHA-256 84de508f471381c6800c3e440dafbe3ce8c6d4173f3aefa7c4bbc10b06cc0b12); commits since the live backend:

- 287be90b fix: resume the day's admitted eBay creations after an interrupted run

## Exact-source validation

Home VM validation passed from 2026-11-24T10:53:56Z to 2026-11-24T11:09:43Z (16 min) with check plan proof=true, browser=functional. Phases: install 53s, source 563s, proof-standard-b 629s, proof-standard-a 643s, proof-recovery 680s, local-stack 815s, backend-scripts 330s, proof-inventory 0s. Backend units: 4969 passed, 0 failed. Browser results: stateful 38, readonly 46, zero unexpected and zero flaky. Multichannel proof: 636 passed exactly once (270 standard-a, 193 standard-b, 173 recovery); 2 TODOs.

Not run, by the change plan: cosmetic visual checks and quick-add repeats (no storefront change). Evidence: /srv/freesplash-ci/admin/benchmark-20261124T105314Z.

## Images

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:a599889b3634f8352b985cf8c67d54c22c8838d7cbd251013674695b9b7e97a2
Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (unchanged)

Rollback target: backend ghcr.io/craigbanach/tcg-store-backend@sha256:e6abf143fa7144e87d4ff2af06462649f74a4f78817cc843f2dd9962ff545cbd (1e845760edb8850ecfc2de09be9440b33486800a), storefront ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). No migrations.

## Managed rollout

Worker drain acknowledged zero active jobs before submission. Every non-release manifest field is preserved; config/catalog execution stay false. Completion requires three consecutive exact-identity readiness checks and a production checkout smoke check (cart, delivery options, Stripe offered, checkout page renders; no payment is created) before the worker resumes.

Submitted 2026-11-24T11:10:39Z; live verification pending.

## Verified completion

At 2026-11-24T11:14:56Z, three consecutive uncached checks confirmed the exact backend and storefront identities, API health and /gb. At 2026-11-24T11:15:16Z the checkout smoke check passed: basket add, GB delivery options, Stripe offered and /gb/checkout rendering the item (test basket emptied; no payment created). The worker drain was resumed with zero active jobs.

GitOps promotion commit: e80fd0a2ec26b587439d307c63b17e4345383f28.
