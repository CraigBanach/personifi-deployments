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

## Submitted promotion

At 2026-11-09T16:59:06.2801115Z the manifest and public endpoints agreed. Previous backend: fd553ebc30f7f3dc66e728b48ee0df39787a5190, ghcr.io/craigbanach/tcg-store-backend@sha256:4ddb1398ef5ad82fcba1ac77469654d20041e45cc12d1e823acb63e503ced7f7. New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:5c9f69e92a8de42795c54ba491ea37ab4b686308442f2203d390ee2f4e64f981. Storefront and runtime flags preserved. Task-owned drain acknowledged zero active jobs. Final public rollout verification pending.
