# One-off release: Boosterhound product identity and stock-filter fix

Operator requested deployment using the established one-off process on 17 November 2026. Exact main source: 70434c0152268bb26640ddcc78bbf61bea51f554; canonical LF archive SHA-256 d5e78ecd77df0f29714e11d3ac7897092e0cc06f20aaa2114c7900d8d0f00327. No GitHub Actions dispatch, workflow change, weaker assertion, retry setting or release gate. Unrelated dirty worktree changes are excluded. Initial validation rejected a CRLF-converted archive before tests; that evidence is retained separately and not accepted.

## Full validation

All six isolated Linux phases passed from 2026-11-17T17:13:00Z to 2026-11-17T17:41:16Z. Backend unit passes: 4813, zero failed. Browser passes: 105 read-only and 38 stateful; zero unexpected/flaky outcomes. Frozen workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs.. Evidence: /srv/freesplash-ci/admin/benchmark-20261117T171218Z; local boosterhound-release-20261117-r3.

## Images and scope

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:794912f1b853cc46b13d146428015ba715d843c57a07192227aadd061db0b052

Storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a

Both are built from the identical validated archive using tracked production Dockerfiles and inspected network-disabled, read-only, as UID 1000. Public Stripe and PostHog configuration preserved from the previous immutable storefront.

Fixes quick-add on mixed-stock grids with per-variant price/availability checks and the lean inventory fields required to make those checks. Unifies checksum-valid barcode and verified bundle/game title policies across product pages and Merchant submissions. Adds a small Boosterhound footer link and referral regression coverage, and a read-only identifier audit command. No public feed, promotion code, affiliate programme, catalogue backfill or Marvel record mutation. No migrations introduced; existing data/config/secrets/feature settings preserved; config/catalog script execution stays false.

Changed files:

apps/backend/src/modules/google-merchant/__tests__/mapping.unit.spec.ts
apps/backend/src/modules/google-merchant/identity.ts
apps/backend/src/modules/google-merchant/mapping.ts
apps/backend/src/scripts/__tests__/audit-merchant-identifiers.unit.spec.ts
apps/backend/src/scripts/audit-merchant-identifiers.ts
apps/storefront/attribution.test.js
apps/storefront/catalog-performance.test.js
apps/storefront/merchant-quality.test.js
apps/storefront/product-identity.test.js
apps/storefront/src/app/[countryCode]/(main)/products/[handle]/page.tsx
apps/storefront/src/lib/data/products.ts
apps/storefront/src/lib/util/product-identity.ts
apps/storefront/src/lib/util/product-search-title.ts
apps/storefront/src/modules/layout/templates/footer/index.tsx
apps/storefront/src/modules/products/components/product-preview/index.tsx
apps/storefront/src/modules/products/templates/product-info/index.tsx
apps/storefront/src/modules/store/templates/paginated-products.tsx
apps/storefront/tests/e2e/quick-add.spec.ts
docs/boosterhound-integration.md

## Rollout and rollback

Task-owned Cardmarket worker maintenance drain confirmed zero active jobs before submission. Require three consecutive exact public source/digest/health checks for both apps, healthy Nomad rollout, and read-only live UI verification before resuming only this task's nonce.

Previous backend/application rollback: fdcfbae1f50b25a74eabd61538a88a35e68b9700, ghcr.io/craigbanach/tcg-store-backend@sha256:ebe8f96c78366165ce2f81019213bef7d56fc7422a18e551e176badb5ad8e766. Previous storefront rollback: d1303e34bd55051bf044e84bc661aeb9ebc335ee, ghcr.io/craigbanach/tcg-store-storefront@sha256:5b3d28f31ae9b4d2ed82bc2b40c226648bf0283abb9ba6ed74325d436c26d4f7. Use a new reviewed GitOps commit for rollback, preserve concurrent releases; never reset the database or replay uncertain provider calls.

Submitted 2026-11-17T17:41:47.293Z; live verification pending.

## Superseded browser expectation

The earlier exact-source validation of 76df67d8 was rejected because the existing browser test asserted that inStock=false removes every quick-add button, which is the reported bug. Commit 70434c01 replaces that expectation with a stronger disposable-local regression: temporarily sell out one seeded SKU, verify in-stock quick-add remains enabled and the sold-out card has no quick-add, then verify stock-only filtering excludes that sold-out card, at both mobile and desktop widths. Exact inventory values are restored in finally. No test is skipped, retry policy altered or timeout relaxed. The previous rejected evidence remains retained in boosterhound-release-20261117-r2.

## Verified completion

GitOps promotion commit: f976489f5642408b11f3c8c4cc60e395c3ee37e4. At 2026-11-17T17:46:42.180Z, three consecutive uncached public checks verified both exact source/digest identities, API health and /gb (all HTTP 200). Nomad deployment 18b5de5a-da67-e9e8-cdb4-f75f75104a9c, job version 340, is successful with both task groups healthy and running.

Read-only live browser verification at 2026-11-17T17:47:30.147Z confirmed available quick-add controls with inStock=true and false at mobile and desktop widths, the Boosterhound footer link, and the Marvel four-deck product's visible/schema title (Set of 4 appears exactly once). All non-GET/HEAD browser requests were blocked; no basket, order, payment, stock or catalogue mutation was performed.

The live Marvel record already explicitly names Set of 4 and its description confirms four decks. No record correction was made. bundle_count metadata is optional additional structure, and a genuine set-level barcode remains absent; do not substitute an individual deck barcode.

The task-owned Cardmarket maintenance drain was resumed with draining=false. Exact validation and both immutable packaged proofs are retained in boosterhound-release-20261117-r3.
