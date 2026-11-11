# One-off backend release - ChatGPT switch fix and Click & Drop query-string images

## Approval and exact-source validation

On 11 November 2026 the operator approved promoting this release, first asking to wait for validation, then (after the previous release's validation showed one retried browser test, purchase-surfaces.spec.ts:10) instructing "Get it promoted anyway" (GitHub Actions jobs are not starting: billing/spending-limit annotation). Pinned main source: 32d263e0c6414395b1a2e9c9bd3b6dc3fbf475b2, which is the live backend 2ee91de398fa52b18b576dce55f68f73296fed4c plus 3b2c1c60 (Click & Drop: query-string image URLs routed through the JPEG copy, another session) and 32d263e0 (ChatGPT feed switch fix and tab mark). No Actions workflow, assertion, retry policy or release gate is changed.

NOT VALIDATED BEFORE PROMOTION: the full isolated Linux validation of this exact archive (home server, frozen workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a) was still running at submission; its outcome is recorded separately. Evidence at submission: the previous release 2ee91de3 completed validation with exit 0, six phases, 105/105 read-only browser checks, 37 stateful with one flaky retry (purchase-surfaces.spec.ts:10, add-address modal still visible after 15 s, passed on retry); local unit tests for the new migration guard and channel credentials; the migration applied locally with the switch saved and removed; and the packaged-image proof below.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:27b5ee4b7afb3461a3843086c873d83a6246666d71ffabb9ee4e6e9ada49d605
- Validation/build archive SHA-256: ab022709d386c60494686ff9e088b33d88b3af93802bc173dafea23f1dbf8e2b
- Previous backend/application rollback target: 2ee91de398fa52b18b576dce55f68f73296fed4c, ghcr.io/craigbanach/tcg-store-backend@sha256:51f2b5066dc3c335bf1015e585f784c37e271cd6c2953c05b27dcf995fa1bf24
- Retained storefront: 245313fdf88b730f491fa3b97f60835aad28f96f, ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2

Changes: Migration20261111170000 adds CHATGPT_FEED_ENABLED to channel_switch_name_check (the switch shipped in 2ee91de3 could not be saved: "An unknown error occurred"), plus a unit test that fails if a Channels-page switch is not allowed by the table; ChatGPT tab shows ChatGPT's favicon as a theme-following mask; Click & Drop image URLs with query strings go through the JPEG copy. The packaged image passed network-disabled, read-only execution as UID 1000 (switch migration present and covering every switch, feed route, ChatGPT tab and mask in the admin bundle, Click & Drop image route). One additive constraint migration (applied and exercised locally: switch saved and removed); the managed migration batch remains enabled with no database rollback or forced replay.

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, then resume only this task's nonce. The previous immutable backend is the application-only rollback target.

Submitted at 2026-11-11T16:29:27.190Z. Verified rollout remains pending; image publication or manifest push alone is not success.

## Verified rollout

At 2026-11-11T16:32:54Z three consecutive checks proved backend 32d263e0c6414395b1a2e9c9bd3b6dc3fbf475b2 at sha256:27b5ee4b7afb3461a3843086c873d83a6246666d71ffabb9ee4e6e9ada49d605, unchanged storefront 245313fd at sha256:2f3c50b7..., API health 200 and /gb 200. Nomad allocation 06f41cb7 (job version 325) running; backend logged "Server is ready on port: 9000" at 16:32:27. This task's Cardmarket drain (which waited for one active job) was resumed. Validation outcome to be recorded separately.
