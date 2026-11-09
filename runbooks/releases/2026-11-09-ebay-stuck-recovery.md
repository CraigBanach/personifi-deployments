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

## Live rollout verified

At 14:58:52 UTC the four public release/health endpoints passed three consecutive
checks. Backend source is `fd553ebc30f7f3dc66e728b48ee0df39787a5190`, image
`sha256:4ddb1398ef5ad82fcba1ac77469654d20041e45cc12d1e823acb63e503ced7f7`.
The storefront remains `ff0e3d1715ff5319218074ef2ef71bca5e487e12`, digest
`sha256:cfddf8b5eb576a67fc2ae368e09ec02154aa525d72891c3996cad36236270aae`.
The task-owned worker drain was resumed with draining=false and zero active
jobs at acknowledgement. Exact operational previews follow deployment; no
settlement was inferred merely from healthy endpoints.

## Applied recovery — 15:00–15:02 UTC

All five canonical previews passed. Fresh preview+apply under the account
coordinator settled every reviewed operation. Independent SQL readback found
**zero unresolved listing operations** for the account. The only provider writes
were deletion of the two exact unpublished offers; no publication, live-listing
withdrawal, stock adjustment, old-owner replay or allowance release occurred.

| SKU | Outcome | Immutable reconciliation |
| --- | --- | --- |
| MTG-LTR-333-NORMAL-NM-EN | Inventory-only attempt cancelled | chebayreconcile_01M70D776A49CAA71J3RW7QCJK |
| MTG-SNC-62-NORMAL-NM-EN | Draft 336938346011 deleted; attempt cancelled | chebayreconcile_01M70D87WS5TS5JFXJ1MJWA2MN |
| MTG-LTR-2-NORMAL-NM-EN | Inventory-only attempt cancelled; currently zero stock | chebayreconcile_01M70D8Y6BEWCQCQ2DR3VSESV2 |
| MTG-LTR-250-NORMAL-NM-EN | Inventory-only attempt cancelled | chebayreconcile_01M70D9KXB22GE7HTV0WDWQXGF |
| MTG-LTR-SBB-EN | Draft 351068276011 deleted; attempt cancelled | chebayreconcile_01M70DAK2CPTMMP1HP5JTTF9Q5 |

All five original allowance slots remain `attempted`, preserving conservative
accounting. Old steps/failures remain retained. These are repaired attempts, not
claims that five new listings were published immediately. Normal future admission
must recheck stock, content, ownership and the remaining allowance.

## Other listing checks and owner actions

Nine stale `fresh_evidence_requires_review` flags were re-evaluated with fresh
authenticated evidence and safely changed to `waiting/daily_creation_schedule`,
with zero provider writes. SKUs: PKM-SCR-97-142-NORMAL-NM-EN,
PKM-PFL-20-94-NORMAL-NM-EN, PKM-MEG-33-132-NORMAL-NM-EN,
PKM-JTG-47-159-NORMAL-NM-EN, PKM-CLB-4-25-HOLOFOIL-NM-EN,
MTG-FRA-155-NORMAL-NM-EN, PKM-30C-8-128-HOLOFOIL-NM-EN,
MTG-TRK-31-NORMAL-NM-EN, MTG-TRK-136-FOIL-NM-EN. Eligibility does not
override daily selection or guarantee publication on a particular day.

At 15:03:27 UTC fresh authenticated evidence and the canonical planner confirmed
the four stocked repaired SKUs (LTR-333, SNC-62, LTR-250 and LTR-SBB) are again
`create` candidates with zero offers and quantities 1, 2, 1 and 4 respectively.
Their statuses were refreshed to `waiting/daily_creation_schedule`. LTR-2 is a
correct zero-stock noop and was marked synchronized with
`no_sellable_stock_for_creation`. No forced daily top-up or new publication was
performed as part of this repair.

Remaining non-operation blockers, deliberately not bypassed:

- **MTG-LTR-2-NORMAL-NM-EN (The Battle of Bywater):** zero available stock;
  restock normally or verify physical quantity if the recorded zero is unexpected.
- **PKM-TTBB-16-264-NORMAL-NM-EN (Phantump):** no inventory level at the reviewed
  warehouse. Verify physical stock and configure its correct native inventory/
  warehouse level. Do not invent quantity or create a second inventory owner.
- **DICE-16-PEARL-BG:** Accessory is not a supported publisher profile. Requires
  reviewed accessory-category/aspect/policy support; do not disguise it as a card.
- **DICE-16-BLACK-NEG / DICE-16-WHITE-POS:** two variants on one product; automatic
  eBay publishing requires a single-variant product. Accessories also need the
  profile above. White's variant has no managed stock level; physically verify
  quantities before any product split or inventory setup.
- **PKM-JTG-188-159-HOLOFOIL-NM-EN (Iono's Bellibolt ex):** protected ended identity
  and zero stock. No action while sold out. Any later publication needs actual
  restock and a reviewed ended-listing transition, not an old-listing resurrection.

Order-linked inventory quarantines are retained, not treated as software errors.
The three with positive recorded availability are MTG-FIN-CMD-CB-EN (2),
MTG-FRA-11-0-14-NORMAL-NM-EN (2), MTG-VOW-DB-EN (32). Owner must confirm
the original order/physical handling and current physical stock before a reviewed
quarantine release; merely editing stock must not remove the protection.

The other quarantined SKUs have zero recorded availability: MTG-EOE-CBB-JP,
mtg-eoe-pbb-en, MTG-LTD-CMD-FOOD-EN, MTG-SNC-151-NORMAL-NM-EN,
MTG-SNC-26-FOIL-NM-EN, PKM-CRI-113-86-HOLOFOIL-NM-EN,
PKM-JTG-180-159-HOLOFOIL-NM-EN, PKM-MEG-165-132-HOLOFOIL-NM-EN,
PKM-PRIZE-PACK-SERIES-CARDS-129-162-HOLOFOIL-NM-EN,
PKM-SCR-164-142-HOLOFOIL-NM-EN, PKM-TEF-129-162-HOLOFOIL-NM-EN.
They require no publication while sold out; any later release needs the same
order/physical review. Existing migrated-binding and SKU-alias protections remain
unchanged; adopting those identities is a separate reviewed migration, not new
listing recovery.

## Submitted promotion

At 2026-11-09T14:55:06.4484969Z the manifest and public endpoints agreed. Previous backend: 7d297714818b99cfb25738cf3036e3a820dcf6cc, ghcr.io/craigbanach/tcg-store-backend@sha256:a14586c44a6b9905aef2bed652e7b637999a2f77c08ee51bcfd1cc87d904afdd. New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:4ddb1398ef5ad82fcba1ac77469654d20041e45cc12d1e823acb63e503ced7f7. Storefront and runtime flags preserved. Task-owned drain acknowledged zero active jobs. Final public rollout verification pending.
