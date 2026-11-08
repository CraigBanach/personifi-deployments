# Cardmarket exact mapping repair and guarded publication

User-authorised one-off non-GitHub-Actions release.

Backend source: `80cec2fa2ead7344d90d65544bd60b059ed482a2`, based on the live
`168db93f1da6a155e12446576a19f8c0f7ee7ab9` source. This preserves the live eBay
price-sync work and does not deploy unrelated current-main changes.

Worker: `1.1.38`, home-server task commit
`3100e345154ebcca4b81b336dbf645192efa0b92`.

## Scope and safeguards

- Repair incomplete mappings by the same retained catalogue ID only. A pack is
  never substituted for a box. Unknown or conflicting identities remain manual.
- Searches run only on idle enabled connections, six items maximum, with a
  six-hour per-product backoff. Native product pages verify sealed IDs.
- Scheduled new publication requires a complete exact game/category route and
  remains bounded to four products. Automatic relisting remains paused.
- Recheck inventory, reservations, shop price +2.5% rounded up, mapping and
  eligibility at claim time. Ten-minute plans are terminal when expired/changed.
  Bundles, ambiguous stock shapes, graded items and accessories are excluded.
- Verify native stock coverage once per bounded category/expansion batch, not
  per product and not as a startup whole-account census. Partial/name-filtered
  reads cannot establish absence. Singles require an exact expansion receipt.
- Refresh cart protection before creation, preserve absolute quantities and
  Cardmarket caps, verify exact quantity and price, and stop on uncertain writes.
- Original uncertain submissions and immutable recovery admissions remain
  untouched; never delete fences, reset attempts, renew or replay admissions.
- No vacation, postage, printing, dispatch, order-status or storefront change.

## First validation attempt

The first full validation of `519a577c` was rejected: two legacy integration
fixtures omitted the now-required catalogue route. Production remained unchanged.
This source supplies an explicit route for those positive fixtures and adds an
integration case proving missing routes remain blocked. No production guard or
validation gate was relaxed. Failed evidence remains at
`/srv/freesplash-ci/admin/benchmark-20261108T223741Z`.

## Validation gate — PASSED

Full isolated exact-SHA Linux validation passed from 2026-11-08T23:11:26Z to 2026-11-08T23:39:10Z. Archive SHA-256: b7e6f7e54243aae983afcb0cfb663ebd1753b2cc8a9fb2ba50a01cc75593853e. All six phases passed; 4148 backend tests; stock-safety inventory: Multichannel proof: 619 passed exactly once (446 standard, 173 recovery); 2 TODOs.. Browser passes: 101 read-only and 38 stateful, zero unexpected/flaky results. Evidence: /srv/freesplash-ci/admin/benchmark-20261108T231045Z. Packaged backend verified network-disabled/read-only as UID 1000. No GitHub Actions run was dispatched.

## Managed rollout

Keep configuration/catalogue mutation disabled and managed migrations enabled.
Drain the browser worker and wait for its current job to finish before restart.
Deploy the versioned worker directory, then promote the immutable backend digest
only if the current manifest and live endpoints still agree with the preserved
baseline. Do not overwrite a concurrent promotion. Verify both exact public
digests and health for three consecutive checks, then resume the owning drain.

Rollback is operator-reviewed, using the actual preceding manifest digest. Never
roll back the database or replay an uncertain listing. Keep worker claims drained
if rollout identity or health cannot be independently confirmed.

## Submitted promotion

At 2026-11-08T23:58:08.0145908Z the manifest and public release endpoints agreed. Previous backend: 168db93f1da6a155e12446576a19f8c0f7ee7ab9, ghcr.io/craigbanach/tcg-store-backend@sha256:2cf6ab9e47fb5fce1dced40a5c3aca29d3cd3d3c1a938ca0076f7ff81a0c139b. New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:da9d9d7d20de45e55d4511f06660173449daf7326c03ea62a1483809a40b6bcf. Storefront and runtime flags preserved. Task-owned drain acknowledged zero active jobs. Final public rollout verification pending.
