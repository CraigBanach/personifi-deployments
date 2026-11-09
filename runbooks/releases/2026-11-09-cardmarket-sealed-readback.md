# Sealed catalogue subtitle read-back and exact guarded binding

Follow-up under the user's approved one-off non-GitHub-Actions deployment.

Backend source: `28f97860cf6386cdc9783724b31dfbc8bf110328`, directly descended
from the verified live `80cec2fa2ead7344d90d65544bd60b059ed482a2` release.
No unrelated current-main application changes are included. Storefront retained.

Worker `1.1.39`, task commit `887a139163a0df25c89dab3bd2ee0808ab906bcf`.

## Evidence and scope

- Exact-ID discovery repaired Unfinity box product `586738` to its correct native
  Booster-Boxes page, without substituting individual booster product `586739`.
- Normal scheduled publication job `chcmjob_01M6YSYXB5FH8JRV3DM2JDRCF9` returned
  submitted / verification_pending for 12 boxes at 14863 pence. Its original
  attempt is retained, unbound and permanently fenced. No listing retry is made.
- Its already-queued scoped stock read `chcmjob_01M6YT3SM6A29C20Q3Y1MB01XX`
  succeeded but produced no positive box match. This is not permission to replay.
- A synthetic regression reproduced the native sealed heading shape: the
  separate `Booster Boxes` category child was included in the product name.
  Worker 1.1.39 removes only that exact separate child, never meaningful
  Collector, Sample Pack, Box, Display or printing/edition words. Singles still
  require their existing expansion subtitle evidence.
- Guarded publication now requires exact quantity and price for independent
  binding, including uncertain submissions. A later positive scoped read may
  establish a matching article without any resubmission or status/reason reset.
- Recovery remains 34 of 35 verified. Togetic's spent pre-browser refusal is
  retained. All original recovery snapshots, one-use admissions and source/job
  fences are preserved. No vacation, postage, dispatch or order-status change.

## Validation gate — PASSED

Full isolated exact-SHA Linux validation passed from 2026-11-09T00:16:15Z to 2026-11-09T00:43:38Z. Archive SHA-256: 11ac06ac10ad5a5373934f86eed9c846731a4a3c1ff4f48707cfc374dd94be53. All six phases passed; 4151 backend tests; stock-safety inventory: Multichannel proof: 619 passed exactly once (446 standard, 173 recovery); 2 TODOs.. Browser passes: 101 read-only and 38 stateful, zero unexpected/flaky results. Evidence: /srv/freesplash-ci/admin/benchmark-20261109T001535Z. Packaged backend verified network-disabled/read-only as UID 1000. No GitHub Actions run was dispatched.

## Managed rollout

Drain without interrupting a current browser job; deploy the versioned worker and
verify its healthy 1.1.39 heartbeat. Preserve existing runtime flags and storefront.
Promote only after all six validation phases and packaged immutable-image proof
pass, and only if manifest/live baseline still agrees with source 80cec2fa. Verify
both exact public digests and health for three consecutive checks before resuming
the task-owned drain. No schema or catalogue mutation is part of this promotion.

Unfinity remains verification-pending unless independent exact positive evidence
is obtained. Neither this source repair nor a normal scheduled job can renew,
reset, delete or replay that original submission.

## Submitted promotion

At 2026-11-09T00:44:09.4411804Z the manifest and public release endpoints agreed. Previous backend: 80cec2fa2ead7344d90d65544bd60b059ed482a2, ghcr.io/craigbanach/tcg-store-backend@sha256:da9d9d7d20de45e55d4511f06660173449daf7326c03ea62a1483809a40b6bcf. New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:b492abbfe8f5ca0cec15f0c27dd08b28b848a5d42825942e410f98f81e1b4b5d. Storefront and runtime flags preserved. Task-owned drain acknowledged zero active jobs. Final public rollout verification pending.
