# One-off backend release - ChatGPT product feed and eBay rejected-price repair

## Approval and exact-source validation

On 11 November 2026 the operator asked to get the ChatGPT product feed "promoted to production using the one-off process" (GitHub Actions jobs are not starting: billing/spending-limit annotation), and chose to ship main HEAD including the earlier eBay commits. Pinned main source: 2ee91de398fa52b18b576dce55f68f73296fed4c, which is the live backend c14685a5ab556a7368103b92d705e5cf20dcdbb8 plus bdfa63c5 (eBay rejected price reductions repaired with reviewed offer rules), 4d7acfc5 (its PostgreSQL proof) and 2ee91de3 (ChatGPT product feed). No Actions workflow, assertion, retry policy or release gate is changed.

NOT VALIDATED BEFORE PROMOTION: the operator explicitly instructed "Get this promoted without waiting for validation." The full isolated Linux validation of this exact archive (home server, frozen workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a) was started at 15:45Z and was still running at submission; its outcome is recorded separately. Pre-promotion evidence: a local backend unit run (170 suites passed; the one failure was a bad barcode in the new ChatGPT test fixture, fixed and re-run green with the Google Merchant suites), clean TypeScript check, a feed build against the local production-catalogue snapshot (3,561 rows), and the packaged-image proof below.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:51f2b5066dc3c335bf1015e585f784c37e271cd6c2953c05b27dcf995fa1bf24
- Validation/build archive SHA-256: 41414b632885d25445257b13413cc8694c6dbbafc1b28831d2e77ea357e2e883
- Previous backend/application rollback target: c14685a5ab556a7368103b92d705e5cf20dcdbb8, ghcr.io/craigbanach/tcg-store-backend@sha256:7764df04f11cf161fe40617a0db2e0cbab199cce9f3d5955fbe1b1d446e529d3
- Retained storefront: 245313fdf88b730f491fa3b97f60835aad28f96f, ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2

Changes: daily (04:30) ChatGPT product feed built a page of products at a time and served from the shared cache at public GET /feeds/chatgpt/products.jsonl.gz (gzipped JSONL, discovery only, checkout stays on the storefront); Channels > ChatGPT admin tab with URL, last-build counts, skip reasons and rebuild; new CHATGPT_FEED_ENABLED switch defaulting off, so nothing is served until the operator turns it on. eBay: rejected price reductions are cancelled into a reviewed 'cancelled_price_rejection' reconciliation and repaired by offer rules. The packaged image passed network-disabled, read-only execution as UID 1000 (feed row fields, GBP price, discovery-only flags, gzipped JSONL build, switch, daily schedule, both routes, eBay migration and admin bundle present). One additive migration (Migration20261111123000 widens channel_ebay_listing_reconciliation_kind_check); the managed migration batch remains enabled with no database rollback or forced replay.

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, then resume only this task's nonce. The previous immutable backend is the application-only rollback target.

Submitted at 2026-11-11T15:57:01.758Z. Verified rollout remains pending; image publication or manifest push alone is not success.

## Verified rollout

At 2026-11-11T15:59:41Z three consecutive checks proved backend 2ee91de398fa52b18b576dce55f68f73296fed4c at sha256:51f2b5066dc3c335bf1015e585f784c37e271cd6c2953c05b27dcf995fa1bf24, unchanged storefront 245313fdf88b730f491fa3b97f60835aad28f96f at sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2, API health 200 and /gb 200. Nomad allocation b66e676e (job version 324) running; backend logged "Server is ready on port: 9000" at 15:59:13. This task's Cardmarket drain nonce was resumed (draining=false, active_jobs=0). The ChatGPT feed URL returns 404 as intended while CHATGPT_FEED_ENABLED is off. Schema check of Migration20261111123000 not performed in this task (production DB reads not permitted to the operator's assistant); home-server validation result to be recorded separately.

## Post-promotion validation

Home-server validation of 2ee91de3 completed after promotion: exit 0, six phases; 105 read-only browser checks clean; stateful 37 passed, 2 skipped, 1 flaky retry (purchase-surfaces.spec.ts:10 at 1440px, add-address modal stuck on Saving after the action returned success in 78 ms; passed on retry); stock-safety proof 633 passed exactly once. Retained evidence /srv/freesplash-ci/admin/benchmark-20261111T154608Z. The strict zero-retry gate is not met; the same storefront stateful flakes recur in earlier releases (8-10 Nov) and are under investigation. The storefront image is unchanged by this release.
