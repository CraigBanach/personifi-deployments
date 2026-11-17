# One-off backend release - marketplace Click & Drop

## Scope and validation

The operator requested the missing Click & Drop path for paid Cardmarket order #204 and standard CardTrader order #200 (Netherlands), then explicitly requested standard/non-Zero CardTrader integration while deferring tax automation. This shipping follow-up is separate from the completed purchasing release. The established operator-approved exact-source one-off release process is retained; no workflow, test assertion or retry policy is weakened.

Pinned main source: fdcfbae1f50b25a74eabd61538a88a35e68b9700. Full isolated Linux validation passed from 2026-11-17T15:27:07Z to 2026-11-17T15:56:29Z, all six phases successful. Backend units: 4811 passed, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Retained evidence: /srv/freesplash-ci/admin/benchmark-20261117T152627Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

Additional exact-source disposable PostgreSQL proof: 83 passing tests, three suites, including real marketplace readiness SQL, lifecycle/settlement guards and Zero exclusions. Focused shipping/account tests, backend/Admin build and generated-type TypeScript checks passed. Packaged image ran network-disabled/read-only as UID 1000: Netherlands draft has no postage service, customs declaration or tax registration; only standard originals qualify; Send/manual-customs guidance, native tracking forwarding and Admin recovery controls are present.

The earlier candidate 789d5c18 was not promoted: first validation (/srv/freesplash-ci/admin/benchmark-20261117T142630Z) had a quick-add keyboard retry, and its repeat (/srv/freesplash-ci/admin/benchmark-20261117T145653Z) had a long-press retry after reading a null button bounding box. Both remain retained as rejected evidence. The operator explicitly requested fixing flaky tests if possible rather than allowing indefinite reruns. This replacement source adds normal locator actionability/visibility/enabled/focus waits before raw mouse/keyboard actions, preserves all behaviour assertions, and skips no additional test. Storefront runtime source and image are unchanged. Supplemental 20 browser executions (10 each for long-press and keyboard) run with retries disabled, in addition to the full unchanged browser suites; all must pass without skip or retry. No existing workflow gate or retry policy is weakened.

The operator also reported the exact Cardmarket postage-mapping refusal. A read-only live account lookup confirmed OLP1SF, Royal Mail Signed For 1st Class, SmallParcel, Signed enhancement. The replacement source maps only the exact normalized buyer label UK Signed For Small Parcel (1st Class), preserving Signed For barcode requirements and exact service/format availability and size checks. Tests reject second class, untracked, smaller/oversized parcels and unknown label variants. No live postage rule or label was changed to work around the mapping.

## Immutable images

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:ebe8f96c78366165ce2f81019213bef7d56fc7422a18e551e176badb5ad8e766
- Validation/build archive SHA-256: d8a98d3740bf0b8eb558e19846e758a346e237cf54d2608cbf214f97c2e0d083
- Previous backend/application rollback target: 85c0415b803a393497d7f348685fedf035818559, ghcr.io/craigbanach/tcg-store-backend@sha256:c53ea1d2af2b366361fd2ade018d83181a4c71487e9d94ace9557cc72dd1d26a
- Retained storefront: d1303e34bd55051bf044e84bc661aeb9ebc335ee, ghcr.io/craigbanach/tcg-store-storefront@sha256:5b3d28f31ae9b4d2ed82bc2b40c226648bf0283abb9ba6ed74325d436c26d4f7

## Behaviour and limits

Marketplace payment authority is checked before the website-only local payment gate; this does not alter payment totals. Standard CardTrader orders require active, picked, intact paid-original evidence and no settlement before carrier preparation. Zero originals/batches remain in their existing workflow. CardTrader is sent as an unserviced draft, with manual buyer-postage and international customs/tax review in Click & Drop. Cardmarket IOSS/VOEC registrations are never reused. Tax automation is explicitly incomplete, not silently represented as clearance.

Existing enabled scheduling may prepare eligible drafts. Carrier creation is reference-idempotent and never purchases postage. Printed labels do not ship CardTrader orders. Confirmed dispatch requires exact carrier identifier and a valid past timestamp; automatic standard CardTrader settlement waits for tracking. Protected CardTrader-first shipment uploads provided tracking before shipping, retains marketplace observation, then settles native stock once with tracking. Untracked parcels use the protected manual channel action after physical handover; later polling recognises completed native settlement. Unknown marketplace attachments cannot fall through to website stock handling. Never mark Arrived from dispatch.

No migration is introduced. No credential, tax registration, payment record, recipient setting, feature gate, config/catalog flag or storefront image is changed. No synthetic production order, manual provider dispatch, label purchase or direct stock mutation is part of verification. The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Preserve the nonce until three consecutive exact public backend/storefront identity and health checks and healthy Nomad rollout, then resume only this task's drain. Do not roll back the database or replay uncertain marketplace shipment calls.

Submitted through GitOps commit `b370da14a6e7bd17c8fe035d6bbb8afc500853fb`. Publication or GitOps push alone was not treated as success. The initial push could not prompt for HTTPS credentials; the same reviewed commit was pushed using the existing GitHub CLI credential helper, with no source/manifest scope change.

## Verified completion

At 16:02:21 UTC, three consecutive uncached public checks verified backend source `fdcfbae1f50b25a74eabd61538a88a35e68b9700` and digest `sha256:ebe8f96c78366165ce2f81019213bef7d56fc7422a18e551e176badb5ad8e766`, unchanged storefront identity and HTTP 200 for API health and `/gb`. Nomad version 339, deployment `d824181a`, is successful; backend allocation `f5a42aab` is healthy, previous allocation completed, and managed migration allocation `8b1b9b8e` completed. No new application migration was introduced. The task-owned maintenance drain was resumed with `draining=false` and zero active jobs.

Final validation: 4,811 backend unit passes, 633 stock-safety cases exactly once, 143 full-suite browser passes and 20 supplemental quick-add repetitions with retries disabled. Zero unexpected/flaky browser outcomes; the same two existing browser skips and two safety-proof TODOs remain explicit. No test was newly skipped. The additional 83-test PostgreSQL proof and all packaged-image checks passed.

Read-only live Admin verification confirms CardTrader order #200 is an active, picked standard original with intact latest evidence, now offering Send to Click & Drop and explicit manual postage/customs review. Cardmarket #204 offers Retry postage preparation; its previous review error remains retained until an operator retries. A live read-only dry run using its real lines, configured weights/rules and current account services selects exactly OLP1SF, Small Parcel, 260 g, with Signed For barcode required. It has no carrier order identifier; this proof created none.

No production Send/Retry, label purchase, dispatch, payment correction or stock mutation was executed as verification. Existing enabled scheduling may prepare eligible drafts normally. International CardTrader customs/tax automation remains deferred; the operator must review those details before buying postage.
