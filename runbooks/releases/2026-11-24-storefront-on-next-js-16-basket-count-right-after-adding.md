# One-off release: Storefront on Next.js 16; basket count right after adding

The first add on a product page sometimes left the header at Basket, empty (about 1 in 10 locally): the page changed its URL on load, basket analytics ran as a second server action, and Next.js 15.5 itself sometimes dropped a correctly received server-action update. Fixes: no URL change on load, analytics as a plain request, an instant header count from the add's returned total, and Next.js 16.4.6 / React 19.2.9 (0 of 60 dropped updates; also brings the 15.5.28/29 security fixes). Adopts Next 16's React lint rules (29 spots fixed or documented), renames middleware to proxy, and gives the 505-listing proof test its own 360s limit.

Owner approval: "Adopt the lint rules, fix the warning. Then get this promoted using the one-off process. (owner, 24 Nov)". Exact main source 7531e318056e33b96a61beccdd1a5915eec74d61 (archive SHA-256 8c61db42fc34c9eceeec9e02b2320b952b1242079eb458dd580b40f1495f03ff); commits since the live backend:

- 7531e318 chore: adopt Next.js 16's React lint rules and rename middleware to proxy
- ce7f9af1 chore: upgrade the storefront to Next.js 16
- fb4c6587 fix: keep the basket count right straight after adding to basket

## Exact-source validation

Home VM validation passed from 2026-11-24T16:06:01Z to 2026-11-24T16:22:27Z (16 min) with check plan proof=true, browser=full. Phases: install 52s, source 612s, proof-standard-a 673s, proof-standard-b 674s, proof-recovery 712s, local-stack 861s, backend-scripts 320s, proof-inventory 0s. Backend units: 4972 passed, 0 failed. Browser results: stateful 38, readonly 105, quick-add-repeat 20, zero unexpected and zero flaky. Multichannel proof: 636 passed exactly once (270 standard-a, 193 standard-b, 173 recovery); 2 TODOs. Evidence: /srv/freesplash-ci/admin/benchmark-20261124T160519Z.

## Images

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:062bb3771d4631663ff7cca9582694027a9c3c753084318d0ca2d249ba539f07
Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:4e441766d9d94c0479ddfcb4993c0780c3b094bae847e38e2b97fa55328e261d

Rollback target: backend ghcr.io/craigbanach/tcg-store-backend@sha256:ecbbf87c18faea5a19bd0e8245ba1609d6d5a005abcbeeee44dba7f9ffbd3466 (1c6b0ef9b1937f0fbe27038e5797cfd1b5e0c91f), storefront ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). No migrations.

## Managed rollout

Worker drain acknowledged zero active jobs before submission. Every non-release manifest field is preserved; config/catalog execution stay false. Completion requires three consecutive exact-identity readiness checks and a production checkout smoke check (cart, delivery options, Stripe offered, checkout page renders; no payment is created) before the worker resumes.

Submitted 2026-11-24T16:23:03Z; live verification pending.

## Verified completion

At 2026-11-24T16:29:00Z, three consecutive uncached checks confirmed the exact backend and storefront identities, API health and /gb. At 2026-11-24T16:29:14Z the checkout smoke check passed: basket add, GB delivery options, Stripe offered and /gb/checkout rendering the item (test basket emptied; no payment created). The worker drain was resumed with zero active jobs.

GitOps promotion commit: c00e7097352a96581a893b5a5f672654d858dd0e.
