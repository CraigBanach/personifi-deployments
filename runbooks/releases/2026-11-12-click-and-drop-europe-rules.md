# One-off backend release - Click & Drop customs codes, Europe postage rules, discard

## Approval and exact-source validation

On 12 November 2026 the operator asked for this to be validated and deployed overnight ("validate this & then get it deployed") while GitHub Actions jobs are not starting (billing/spending-limit annotation). Pinned main source: 8882e4a980715a465032a01db86c45b4ab650e51, which is the live backend 7297fc066bb568b605ad44f55f31d799b06e9d7c plus exactly three commits (3df71980, b681dfac, 8882e4a9). No Actions workflow, assertion, retry policy or release gate is changed.

Full isolated Linux validation passed from 2026-11-12T00:35:20Z to 2026-11-12T01:04:39Z, all six phases successful. Backend units: 4554 passed, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Retained evidence: /srv/freesplash-ci/admin/benchmark-20261112T003441Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:0af2af8ef81409e345efe2ff03522239e4b848bd6fad452b2723f585c0db78e5
- Validation/build archive SHA-256: 37a8104cf150dd809708577a56a5001a2d52118e9673140714b16c80bb986c10
- Previous backend/application rollback target: 7297fc066bb568b605ad44f55f31d799b06e9d7c, ghcr.io/craigbanach/tcg-store-backend@sha256:08cfaf0320716ff1f374d09f9133bdf5ca65ae998ad747dea8afad02afc50ef9
- Retained storefront: 245313fdf88b730f491fa3b97f60835aad28f96f, ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2

Changes: (1) each international customs line's HS code and country of origin come from the product's Medusa fields (variant first), with missing ones sending the order to review; Cardmarket IOSS/VOEC numbers move to Channels -> Cardmarket -> Settings (Migration20261112004500, additive, copies numbers saved on the Click & Drop page). (2) Postage rules gain Orders (website & CardNexus / Cardmarket) and Destination (UK / Europe); a matching Cardmarket rule replaces the buyer's exact method if the destination offers it and it keeps paid-for tracking; Europe rules must be large letter or bigger (no IOSS on letters). Migration20261112013000 adds the columns (existing rules keep their meaning) and seeds the owner's rule: Cardmarket singles to Europe, £20 to under £50, International Tracked (ITROLP) large letter. (3) Order page action to discard a Click & Drop order the owner has deleted there, refusing while Click & Drop still has it or once it has tracking/despatch. Application rollback to 7297fc06 is safe: it ignores the new columns and the seeded rule (old code never applies channel/destination, so the seeded rule row would then match UK website orders only if moved above the others; it is last). The packaged image passed network-disabled, read-only execution as UID 1000 (product codes, Norway/VOEC, Europe rule to ITROLP large letter, missing codes to review, US review, website UK-only, tax-number validation, discard action, routes and migrations present).

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, then resume only this task's nonce. The previous immutable backend is the application-only rollback target.

Submitted at 2026-11-12T09:06:35.617Z. Verified rollout remains pending; image publication or manifest push alone is not success.
