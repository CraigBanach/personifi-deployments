# One-off backend release - Click & Drop product images

## Approval and exact-source validation

On 11 November 2026 the operator asked to "Validate & promote using the one-off process" (GitHub Actions jobs are not starting: billing/spending-limit annotation). Pinned main source: c14685a5ab556a7368103b92d705e5cf20dcdbb8, which is the live backend 594ef3a9346a74dd7de30d6e8120dfe4dc247a0c plus only two Click & Drop commits (efde8f7b, c14685a5). Later main commits from another session (eBay rejected-price repair bdfa63c5, 4d7acfc5) are deliberately excluded. No Actions workflow, assertion, retry policy or release gate is changed.

Full isolated Linux validation passed from 2026-11-11T13:34:47Z to 2026-11-11T14:03:58Z, all six phases successful. Backend units: 4512 passed, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Retained evidence: /srv/freesplash-ci/admin/benchmark-20261111T133407Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 632 passed exactly once (459 standard, 173 recovery); 2 TODOs.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:7764df04f11cf161fe40617a0db2e0cbab199cce9f3d5955fbe1b1d446e529d3
- Validation/build archive SHA-256: b36309fb72831cf92563a542c706555c8fd8e5cb17e3dbb2e3a49db5562fabed
- Previous backend/application rollback target: 594ef3a9346a74dd7de30d6e8120dfe4dc247a0c, ghcr.io/craigbanach/tcg-store-backend@sha256:3174310d855133cb937600a127aa805829be47dd2e96b3acc45b85b51ac8f73d
- Retained storefront: 245313fdf88b730f491fa3b97f60835aad28f96f, ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2

Changes: Admin Click & Drop page "Product images" download (GET /admin/click-and-drop/product-file, CSV of SKU/Name/Image URLs for Click & Drop Products -> Import); public GET /click-and-drop/image/<SKU>.jpg re-encoding a published product's WebP thumbnail as JPEG (looked up by SKU, never a caller-supplied URL); "Default variant" dropped from Click & Drop line names. The packaged image passed network-disabled, read-only execution as UID 1000 (CSV shape, WebP rewrite, quoting, line naming, both routes present, sharp WebP->JPEG). No new migrations; the managed migration batch remains enabled with no database rollback or forced replay.

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, then resume only this task's nonce. The previous immutable backend is the application-only rollback target.

Submitted at 2026-11-11T14:29:05.372Z. Verified rollout remains pending; image publication or manifest push alone is not success.
