# One-off exact Release Promos route deployment — 8 November 2026

Operator explicitly requested deployment and continuation of guarded recovery.
Use the existing approved non-GHA exact-source validation/build and GitOps method.

## Scope and artifact

- Source: `168db93f1da6a155e12446576a19f8c0f7ee7ab9`, retained in application main ancestry by tree-preserving merge `3c9148e8`.
- New backend: `ghcr.io/craigbanach/tcg-store-backend@sha256:2cf6ab9e47fb5fce1dced40a5c3aca29d3cd3d3c1a938ca0076f7ff81a0c139b`.
- Previous backend: `ghcr.io/craigbanach/tcg-store-backend@sha256:18e3f7861fcd311fa6264b245b6c5a1862a4bd4cb247ed9d853b14e6dfa768d3`, source `a0ef49bdb87946d202c54266fb0b0c12a9dbb602`.
- Preserve storefront: `ghcr.io/craigbanach/tcg-store-storefront@sha256:cfddf8b5eb576a67fc2ae368e09ec02154aa525d72891c3996cad36236270aae`.
- Exactly two changed files versus the running eBay-price-sync backend: six exact Cardmarket product routes and their tests. No new migrations, runtime flags, credentials, marketing sends, stock corrections or feature activation.
- Six exact Magic IDs map to `Release Promos`: 273116, 269592, 266641, 292524, 271515, 266069. Native corrected-foil preview `chcmjob_01M6Y59BJ83GCVGHSFT2EWQB0C` proved each row. Unknown IDs, other games and whole-series aliases are unchanged.
- This corrects a pre-admission refusal: preview scope `Release Promos` differed from the old canonical series name. No admission/live write occurred for that refusal.

## Validation

Exact canonical archive SHA-256: `c32c08e6374bf2cc23932461f3a6ff1d4b2a50d3be444cd66d71b7dd66f42b89`.
Frozen workflow hash: `7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a`.
Build and validation source archives match.

Full isolated Linux run 18:59:35–19:25:59 UTC passed every phase: install,
source, local-stack, proof-standard, proof-recovery, proof-inventory.

- 4,140 backend unit passes; zero failures; 47 opt-in/pending, four TODO.
- 618 multichannel cases passed exactly once (445 standard, 173 recovery), two TODOs.
- 101 read-only and 38 stateful browser passes; zero final failures or flaky retries.
- Two existing conditional browser skips: unconfigured Stripe payment and optional authenticated eBay Admin test. Actual price-edit runtime proof passed.
- Fresh migrations, builds, SQL/email/marketing checks, lint and types passed.
- Root-owned evidence `/srv/freesplash-ci/admin/benchmark-20261108T185853Z`; guest destroyed after collection. Local approved-temp evidence directory: `backend-routes-current-live-20261108`.
- Network-disabled/read-only non-root image inspection confirmed exact source and all six routes, with no unknown-ID/foreign-game substitutions.

Earlier source `b7fa3c0b` was superseded after another session deployed eBay
price syncing. Its validator was gracefully interrupted by exact owned process
identity, using the existing teardown/evidence finally block. It is not successful
release evidence and its built image must not be promoted over the newer backend.
No other session's run/lock was interrupted; only the replacement above counts.

## Rollout and operational limits

Confirmed live source and manifest still match `a0ef49bd` before promotion.
Worker maintenance drain acknowledged zero active jobs. Preserve managed rollout,
config/catalog-off flags, the existing probes and all other manifest settings.
Require three consecutive exact backend/storefront digest, API-health and `/gb`
checks, then verify the live resolver and resume only this drain's matching nonce.

Hall remains verified from the prior one-use recovery; the remaining 34 original
uncertain submissions have not been retried. Deployment does not renew old
evidence, create an admission or reset a fence. Refresh census/order/preview
evidence as necessary before subsequent one-use admissions.

Status: validated, promotion/live verification pending.
