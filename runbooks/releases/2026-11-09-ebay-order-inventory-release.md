# Reviewed eBay order inventory release

Owner requested Heartwood token stock propagation, native settlement for Crimson
Vow, and confirmed Counter Blitz restock. This release separates publication
quarantine from permanent historical original-order replay protection.

Source: actual published main `fb13b7cc93d5bcb2f1fb7f4f70f6e21c44a18aec`.
Backend includes current committed main; storefront/runtime configuration remain
unchanged for this backend-only operational repair. Unrelated dirty work excluded.

## Native settlement completed before deployment

Owner-authorized canonical `settle-ebay-picked-dispatch.ts` preview for native
order `order_01M4ZEXN9P5DKF8JP1FK5G9E7N` (Crimson Vow), exact eBay package
`0505060B286`, passed fresh authenticated package/original/pick/reservation checks.
Preview fingerprint `31d3d8b30a3a6331a59b813e0484754124187123d95dbc4328758bf6f7bdf214`
was explicitly confirmed. At 15:35:29 UTC its completed shipped receipt pointed to
native fulfillment `ful_01M70F6EE04KPZQD6AG69VEQRB`, quantity one, retained pick
`chpluginpick_01M521TJRTF47NVMYCNSZQ4SVY`. The process used active mode only in
the one-off operational process; no global switch or running service was changed.
This consumed the original native commitment without another shelf decrement or
remote dispatch write. Deferral retained; no new order or stock adjustment.

## Reviewed release scope

- Heartwood token: deferral `chebaydefer_01M52FJA2WB41DSJHA0W13B0K3`, native
  order `order_01M4ZYE4NAPPA6FVZWF2NTHRW6`, five units consumed by existing
  shipped fulfillment `ful_01M574J598JNBV50VKSM49MNDZ` and completed shipment
  effect; zero remaining original reservations. Owner says additional stock added.
- Crimson Vow: deferral `chebaydefer_01M52FJ9CKEVQD2WZNEG0WVM2W`, exact
  native settlement above. Release only after independent completion proof.
- Counter Blitz: deferral `chebaydefer_01M50TB4YRGY5PAEV4F0FV6W1W`, original
  `26-15264-55388`, external fulfillment; fresh eBay read confirms shipped.
  Owner confirms restock; preserve this as explicit owner-restock evidence, never
  claim native stock consumption or subtract the historical order again.

No release is inferred from stock edits alone. Before deployment the exact new
release-readiness SQL was evaluated read-only against production: all three
reviewed cases satisfied their independently checked native/external prerequisites.

## Validation gate — PASSED

Full isolated exact-SHA Linux validation passed from 2026-11-09T16:30:05Z to 2026-11-09T16:58:43Z. Archive SHA-256: fdfdefa9a0b8ea8bcc16d6558f822338a8af818dc04133b56bc02e835e8973a3. All six phases passed; 4492 backend tests; stock-safety inventory: Multichannel proof: 632 passed exactly once (459 standard, 173 recovery); 2 TODOs.. Browser passes: 105 read-only and 38 stateful, zero unexpected/flaky results. Evidence: /srv/freesplash-ci/admin/benchmark-20261109T162927Z. Packaged backend verified network-disabled/read-only as UID 1000. GitHub promotion 42607935677 failed before jobs started; this one-off run used no additional GitHub Actions.

## Managed rollout

Continue the previously approved one-off route while hosted Actions is blocked by
billing. Validate exact published-main archive, build/push immutable backend,
verify its packaged code network-disabled/read-only as UID 1000, drain only the
task-owned Cardmarket worker, and promote the managed GitOps manifest. Preserve
storefront and runtime flags; verify three consecutive public release/health checks
before resuming the task-owned drain. No raw SQL status or quantity repair.

After live verification, freshly preview/apply only the three reviewed releases
under the account coordinator. Record immutable receipt IDs, stock readback,
native commitment state and provider stock propagation/remaining blockers.

Rollback requires review: migration refuses removal while release receipts exist.
Original deferral/observation, order import, reservation admission, attachment and
effect replay guards are intentionally unchanged. Publication revalidates full
native evidence on every read; drift re-quarantines, and later independent
deferrals sharing the inventory still veto every alias.

## Live rollout verified

Three consecutive exact public backend/storefront release and health checks
passed at 17:02:00 UTC. Live backend `fb13b7cc93d5bcb2f1fb7f4f70f6e21c44a18aec`,
digest `sha256:5c9f69e92a8de42795c54ba491ea37ab4b686308442f2203d390ee2f4e64f981`.
Storefront source/digest remain unchanged. The task-owned worker drain was resumed
with zero active jobs acknowledged. First release previews returned `busy` because
scheduled eBay work held the account coordinator; no receipt or stock write occurred.
Operational previews now queue on the exact same `ebay-runtime:<connection>`
session advisory key, with a dedicated connection and a ten-minute lock timeout,
never bypassing or terminating the scheduled owner.

The superseded c859cc59 candidate's full validation also exposed its already-known
SWC inline-type issue in crash-worker startup. It was never promoted. The corrected
fb13b7cc candidate passed all six phases, 4,492 unit tests, 632 stock proofs and
143 browser checks without retries; two pre-existing TODO proofs remain explicit.

## Applied inventory releases — 17:13 UTC

All three fresh, account-verified previews passed. Apply repeated the authenticated
fulfilled-order read and database prerequisites, then appended these exact receipts:

| SKU | Kind | Retained receipt |
| --- | --- | --- |
| MTG-FRA-11-0-14-NORMAL-NM-EN | native_dispatch | chebaystockrelease_01M70MSAVHGJTMET412Q16TXAX |
| MTG-VOW-DB-EN | native_dispatch | chebaystockrelease_01M70MSCP0DGGZ85CJAH0REWHQ |
| MTG-FIN-CMD-CB-EN | owner_restock | chebaystockrelease_01M70MSEJZE5KERGMTACN3KC4F |

Release preview fingerprints respectively:
`4e3088e42aff4eb5a524729a64a71610e33f98249db995d80b31f51b05928231`,
`37604245408b08ba3b5a783ea917cfff55fafed240dc1670898c72a9cfeabe55`,
`6c8b7043f19a899bcd028f21db9b58bcfd99330b59e4aaa422c6989ec5e76760`.
Each release wrote neither provider state nor native stock. Independent SQL after
application verified all three release predicates true; current availability
remains Heartwood=2, Crimson Vow=32, Counter Blitz=2. Both native originals retain
completed exact shipment effects and zero original reservations. Historical
deferrals, blocked observations and replay guards remain intact.

## Stock propagation / separate legacy-listing blockers

At 17:13:40 UTC the ordinary durable stock engine synchronized Crimson Vow to 32;
fresh eBay GET at 17:16:32 verified published offer `306849191011`, live item
`137830532863`, quantity 32. No manual absolute stock adjustment or direct provider
write bypass was used. Native shelf stock was not decremented again.

Heartwood and Counter Blitz cannot be restored by a quantity push: neither has
a current reviewed live stock binding. Canonical discovery now reports
`migrated_binding_removed_no_lifecycle_writes` rather than order quarantine.
Exact fresh provider evidence:

- Heartwood `289531663011` / `137799914813`: **UNPUBLISHED**, listing status
  **OUT_OF_STOCK**, quantity 0. Native availability 2. The writer deliberately
  accepts PUBLISHED/OUT_OF_STOCK replenishment, not an UNPUBLISHED offer.
- Counter Blitz `266739296011` / `137741068381`: **UNPUBLISHED**, listing status
  **ENDED**, quantity 2. Native availability 2; its old stock link is retired.

Both identities belong to the retained pre-cutover enrollment cohort, not the
native stockout-end/relist lifecycle. The Nov 2 adoption policy explicitly expires
nonlive legacy bindings without relisting. A reviewed legacy-restock transition
is required to create/relist these safely, preserve exact predecessor provenance,
establish current native stock/order coverage and obey ordinary publication quota.
Do not clear enrollment, erase old links, synthesize native withdrawal receipts,
reinsert an expired binding or retry publication outside the listing journal.
No such extra relisting was performed in this order-protection repair.

Listing-status readback was refreshed using canonical discovery/planning. Crimson
Vow has a separate `medusa_listing_drift` content proposal; its quantity is already
verified at 32 and no content was overwritten by this repair.

## Submitted promotion

At 2026-11-09T16:59:06.2801115Z the manifest and public endpoints agreed. Previous backend: fd553ebc30f7f3dc66e728b48ee0df39787a5190, ghcr.io/craigbanach/tcg-store-backend@sha256:4ddb1398ef5ad82fcba1ac77469654d20041e45cc12d1e823acb63e503ced7f7. New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:5c9f69e92a8de42795c54ba491ea37ab4b686308442f2203d390ee2f4e64f981. Storefront and runtime flags preserved. Task-owned drain acknowledged zero active jobs. Final public rollout verification pending.
