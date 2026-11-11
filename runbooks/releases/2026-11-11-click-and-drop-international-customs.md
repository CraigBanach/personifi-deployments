# One-off backend release - Click & Drop international customs

## Approval and exact-source validation

On 11 November 2026 the operator approved this release ("You do 1": validate and promote) while GitHub Actions jobs are not starting (billing/spending-limit annotation). Pinned main source: 7297fc066bb568b605ad44f55f31d799b06e9d7c, which is the live backend 6f35aaf91730e43d4e9a245a6b6370bb57ccf988 plus exactly one commit (7297fc06). No Actions workflow, assertion, retry policy or release gate is changed.

Full isolated Linux validation passed from 2026-11-11T22:40:17Z to 2026-11-11T23:09:41Z, all six phases successful. Backend units: 4543 passed, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Retained evidence: /srv/freesplash-ci/admin/benchmark-20261111T223939Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:08cfaf0320716ff1f374d09f9133bdf5ca65ae998ad747dea8afad02afc50ef9
- Validation/build archive SHA-256: 2a7d8c33a190f209e093387f9cfcde184f129058dcd204410addb51caa09d0e2
- Previous backend/application rollback target: 6f35aaf91730e43d4e9a245a6b6370bb57ccf988, ghcr.io/craigbanach/tcg-store-backend@sha256:2aa72f3196444b95ae8c1c8643665e6d77f1f3296de8aafc8e46d350fe6d523d
- Retained storefront: 245313fdf88b730f491fa3b97f60835aad28f96f, ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2

Changes: Cardmarket orders to EU and Norway addresses can be sent to Click & Drop (International Standard small parcel for "Int. Standard Small Parcel (Online)"), with a customs declaration (description, HS code, origin, SKU reference, eCommerceSaleOfGoods) and Cardmarket's IOSS (EU) or VOEC (Norway) number. Customs details are admin data on the Click & Drop page; blank until set, so international orders keep waiting for review until then. Other destinations, website and CardNexus orders remain UK-only. One additive migration (Migration20261111224500: new click_and_drop_customs_setting table plus one blank row); application rollback leaves it harmlessly unused. The packaged image passed network-disabled, read-only execution as UID 1000 (Norway/VOEC mapping, ISOLP small parcel, customs fields, US still review, website still UK-only, route and migration present).

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, then resume only this task's nonce. The previous immutable backend is the application-only rollback target.

Submitted at 2026-11-11T23:46:26.764Z. Verified rollout remains pending; image publication or manifest push alone is not success.
