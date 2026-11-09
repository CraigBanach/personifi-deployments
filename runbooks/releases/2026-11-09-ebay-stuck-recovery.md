# Owner-approved eBay stuck-listing recovery

The operator requested repair of every safely recoverable stuck eBay listing,
with an explicit list of unresolved items and required actions. Source is actual
published main `fd553ebc30f7f3dc66e728b48ee0df39787a5190`.

Read-only authenticated production audit found five uncertain creations:

- `MTG-LTR-333-NORMAL-NM-EN`: acknowledged inventory; no offer request, no offer/listing.
- `MTG-LTR-2-NORMAL-NM-EN`: same shape; current stock is independently rechecked.
- `MTG-LTR-250-NORMAL-NM-EN`: same shape; no offer/listing.
- `MTG-SNC-62-NORMAL-NM-EN`: exact acknowledged draft `336938346011`, unpublished,
  no listing; publish attempted but never dispatched.
- `MTG-LTR-SBB-EN`: exact acknowledged draft `351068276011`, same undispatched shape.

Three inventory-only attempts cannot use the older current-intent cancellation
because native stock/content changed. The new explicit `cancelled_inventory_only`
outcome abandons only exact retained inventory whose offer request never began;
it still requires fresh account-bound absence proof, matching original staged
inventory, immutable heads/snapshot, no competing owner/legacy link/quarantine,
and an attempted original allowance slot. No provider or stock write occurs.
The old owner stays revoked and its slot remains conservatively attempted.
Future publication requires an independently admitted new generation.

Draft discard recognises a guard failure after publish start but before dispatch,
while refusing unknown dispatched publications. Every delete still independently
verifies the sole exact unpublished draft with no listing ID or seller match.

## Validation gate — PASSED

Full isolated exact-SHA Linux validation passed from 2026-11-09T14:25:21Z to 2026-11-09T14:54:10Z. Archive SHA-256: 13132fc7719420034bd05eb84c1c89705b30e8e67e71fe104e17513bb23a1234. All six phases passed; 4456 backend tests; stock-safety inventory: Multichannel proof: 630 passed exactly once (457 standard, 173 recovery); 2 TODOs.. Browser passes: 101 read-only and 38 stateful, zero unexpected/flaky results. Evidence: /srv/freesplash-ci/admin/benchmark-20261109T142442Z. Packaged backend verified network-disabled/read-only as UID 1000. GitHub promotion 42607935677 failed before jobs started; this one-off run used no additional GitHub Actions.

## Managed rollout

Use the established owner-approved one-off route because GitHub hosted billing
prevents starting the promotion workflow. Publish a verified immutable backend,
preserve the current storefront and runtime flags, drain the task-owned worker,
then let serialized GitOps migrate and roll out the service. Verify exact public
backend/storefront identities and health three consecutive times before resume.

Operational settlement is separate from deployment: acquire the account runtime
coordinator, preview each pinned operation against fresh eBay reads, then apply
only the canonical supported outcome with its exact snapshot. Do not update
status by raw SQL, release old quota, manufacture stock or replay old owners.
Record each outcome, remaining blockers and any requested fresh publication.

Rollback requires review of the new append-only cancellation evidence; the
migration refuses rollback while that outcome is retained. Never roll back schema
or replay uncertain provider writes automatically.

## Submitted promotion

At 2026-11-09T14:55:06.4484969Z the manifest and public endpoints agreed. Previous backend: 7d297714818b99cfb25738cf3036e3a820dcf6cc, ghcr.io/craigbanach/tcg-store-backend@sha256:a14586c44a6b9905aef2bed652e7b637999a2f77c08ee51bcfd1cc87d904afdd. New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:4ddb1398ef5ad82fcba1ac77469654d20041e45cc12d1e823acb63e503ced7f7. Storefront and runtime flags preserved. Task-owned drain acknowledged zero active jobs. Final public rollout verification pending.
