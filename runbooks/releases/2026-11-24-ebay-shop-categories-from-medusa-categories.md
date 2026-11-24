# One-off release: eBay shop categories from Medusa categories

Owner wants every eBay listing placed in the custom eBay shop category matching its Medusa category, automatically.

Owner approval: "I'm going to bed, prove this out & get it deployed using the one-off process if you're confident in the implementation.". Exact main source 1e845760edb8850ecfc2de09be9440b33486800a (archive SHA-256 537364eeab39efe28044c4ff57199dd71349b25856988a9fc17da11cc50be2b1); commits since the live backend:

- 1e845760 feat: place eBay listings in shop categories from their Medusa categories
- 16120c26 ci: run validation lanes in parallel and pick checks from what changed

## Exact-source validation

Home VM validation passed from 2026-11-24T00:05:34Z to 2026-11-24T00:22:55Z (17 min) with check plan proof=true, browser=full. Phases: install 52s, source 580s, proof-standard-b 675s, proof-standard-a 678s, proof-recovery 736s, backend-scripts 388s, local-stack 989s, proof-inventory 0s. Backend units: 4966 passed, 0 failed. Browser results: stateful 38, readonly 105, quick-add-repeat 20, zero unexpected and zero flaky. Multichannel proof: 636 passed exactly once (270 standard-a, 193 standard-b, 173 recovery); 2 TODOs. Evidence: /srv/freesplash-ci/admin/benchmark-20261124T000452Z.

## Images

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:e6abf143fa7144e87d4ff2af06462649f74a4f78817cc843f2dd9962ff545cbd
Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (unchanged)

Rollback target: backend ghcr.io/craigbanach/tcg-store-backend@sha256:0a014e17d4794d2073fc61286771a002fd639f4bb9f88e93f61ed04cf891bf95 (f472ee542561e8a93c5158c39954542de57ca663), storefront ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). This release includes migrations (apps/backend/src/modules/channel-sync/migrations/Migration20261123233000EbayStoreCategory.ts): automatic rollback is disabled.

## Managed rollout

Worker drain acknowledged zero active jobs before submission. Every non-release manifest field is preserved; config/catalog execution stay false. Completion requires three consecutive exact-identity readiness checks and a production checkout smoke check (cart, delivery options, Stripe offered, checkout page renders; no payment is created) before the worker resumes.

Submitted 2026-11-24T00:23:39Z; live verification pending.

## Verified completion

At 2026-11-24T00:29:15Z, three consecutive uncached checks confirmed the exact backend and storefront identities, API health and /gb. At 2026-11-24T00:29:27Z the checkout smoke check passed: basket add, GB delivery options, Stripe offered and /gb/checkout rendering the item (test basket emptied; no payment created). The worker drain was resumed with zero active jobs.

GitOps promotion commit: 434601c524d73c721089d40be467899d3d44da55.
