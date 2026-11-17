# One-off backend release - purchase product selection and approved alerts

## Approval and exact-source validation

On 17 November 2026 the operator requested deployment of catalogue-backed purchasing through the established one-off process. They explicitly approved including the pending Channels alert-recipient controls and payment/capture alerts. When main advanced, they separately selected Include and validate for exact sealed Cardmarket split-sale recovery plus the alert mailbox constraint correction. No Actions workflow, assertion, retry policy or release gate is changed.

Pinned main source: 85c0415b803a393497d7f348685fedf035818559. Full isolated Linux validation passed from 2026-11-17T13:36:56Z to 2026-11-17T14:05:07Z, all six phases successful. Backend units: 4762 passed, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Retained evidence: /srv/freesplash-ci/admin/benchmark-20261117T133617Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

Additional purchasing checks passed 818 scoped tests, 32 HTTP journeys, TypeScript, standalone disposable purchasing proof and backend/Admin builds, plus 105 targeted combined-main tests and the real catalogue-selection HTTP proof. The alert correction passed 75 disposable PostgreSQL tests and 72 focused settings/payment/transactional-email tests. The final exact release additionally passed 88 PostgreSQL tests across worker, historical-exclusion, sealed split-recovery and corrected mailbox constraints (three suites). These supplement, not replace, full exact-release Linux verification above.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:c53ea1d2af2b366361fd2ade018d83181a4c71487e9d94ace9557cc72dd1d26a
- Validation/build archive SHA-256: a5e04205cf76cbb788ad024acedf28a087c2ce72ece839f9d6f1b47a91756be9
- Previous backend/application rollback target: e92e9c3fc20f6a6c23b061f17f1b93b4851da95b, ghcr.io/craigbanach/tcg-store-backend@sha256:1ad021be4e1923354e5aeabd6d09a11dbc226ab227894cc7aaaa2b715b7a5c14
- Retained storefront: d1303e34bd55051bf044e84bc661aeb9ebc335ee, ghcr.io/craigbanach/tcg-store-storefront@sha256:5b3d28f31ae9b4d2ed82bc2b40c226648bf0283abb9ba6ed74325d436c26d4f7

The packaged image passed network-disabled, read-only execution as UID 1000: existing draft/proposed purchase selection, server-derived immutable titles/SKUs, missing/foreign selection refusal, private search headers and packaged Admin selector. Alert-recipient routes, payment health scheduler and both new migrations are present. No actual mail or provider request is sent by this proof.

New purchases require existing Medusa catalogue selections. Draft/proposed products do not need publication, price or inventory; product-only lots are allowed before variants exist. Existing purchases and exact old retries are preserved, with no identity backfill, stock movement or automatic cost allocation. Catalogue renames/deletions never rewrite retained terms.

Production advanced independently to e92e9c3f before this promotion: the alert controls/payment monitor and initial channel_alert_email migration are already live. The exact public backend identity and manifest were re-read, and the preflight guard now requires that specific prior source/digest; the storefront remains d1303e34. The corrected mailbox constraint is the only new migration relative to that live source. The initial migration's JavaScript template consumed regex backslashes: the emitted SQL excluded the letter s and allowed a wildcard domain separator. A forward migration preserves that earlier history while requiring real whitespace exclusion and a literal domain dot. A read-only preflight found zero recipient rows and therefore no invalid existing rows. Existing invalid rows would otherwise fail validation for operator review, never be removed. The first candidate 41a07cd1 was stopped before promotion; its partial validation and unused published image are not accepted release evidence. Only the replacement exact SHA above is eligible. Failed/uncertain migrations block rollout; no database rollback or forced replay is attempted.

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Existing credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. No provider listing update, order replay, payment/capture/refund, dispatch, physical-stock correction, accounting posting or synthetic production purchase is authorised for release verification. We do not configure recipients or send test alerts. Payment monitoring is read-only and remains gated by its existing recipient setting; natural approved schedulers may emit deduplicated operational alerts. Sealed split recovery retains its reviewed exact-source/quantity/provenance guards and uses the normal fenced intake, not an independent marketplace writer. Broader accounting features remain outside MVP.

Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, and Nomad is healthy. Resume only this task's nonce. The previous immutable backend is the application-only rollback target; no schema rollback is attempted.

Submitted at 2026-11-17T14:09:16.6216362Z. Verified rollout remains pending; image publication or manifest push alone is not success.