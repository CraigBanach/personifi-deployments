# One-off backend promotion — Medusa to eBay price maintenance

## Approval and pinned scope

The operator explicitly requested deploying the eBay pricing change using the
previously agreed one-off promotion process. This release-specific exception uses
full isolated Linux validation and a locally built immutable image; no GitHub
Actions validation/build/promotion is dispatched. Normal deployment policy is
unchanged.

- Exact main source: `a0ef49bdb87946d202c54266fb0b0c12a9dbb602`.
- Task source commit: `063e733f`, cherry-picked to main as `a0ef49bd`.
- Initial rollback backend source: `7296a1d58e712bcf86edc3fe1ed1e96053a202c9`.
- Initial rollback backend digest:
  `sha256:de562b91acae77f0390a43da8dfdbecb620e198c44b162b3031d2f3c6aa5c545`.
- Storefront remains digest
  `sha256:cfddf8b5eb576a67fc2ae368e09ec02154aa525d72891c3996cad36236270aae`.

Main also contains the preceding committed campaign catalogue fix. No unrelated
dirty-worktree changes are included. Config/catalog application stays disabled;
credentials, runtime gates and managed migration controls are preserved.

The eBay lifecycle now maintains prices on live retained/adopted and creation-only
listings using a journaled price-only provider call. Titles, images, quantities,
policies, Best Offer settings and listing IDs remain unchanged by that path.
Explicit price overrides and existing conversion/uplift rules remain authoritative.
Ended listings, protected SKU aliases, missing/ambiguous GBP prices and unresolved
ownership remain blocked. Scheduling remains the hourly bounded listing sweep.
No manual listing replay, stock adjustment, campaign send or configuration
activation is performed by this promotion.

## Validation gate — PENDING

The exact-SHA canonical LF archive must pass the complete frozen Validate mirror:
install, source, local-stack, proof-standard, proof-recovery and proof-inventory.
Workflow hash: `7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a`.
Earlier focused tests are not a substitute. The build archive hash must match
validation, and the packaged image must prove its source, non-root identity and
compiled price-maintenance paths with network disabled.

## Managed rollout and recovery

Re-read the current manifest and both uncached public release endpoints. Require
the currently live backend to be an ancestor of this source; never overwrite a
concurrent release or roll back another operator's work. Record the actual
rollback image immediately before promotion. Drain Cardmarket with this task's
unique nonce and require zero active jobs. Do not take over another drain.

Update only backend release identity and the audit pointer; preserve storefront
digest and all runtime/config/catalog flags. Use the existing serialized managed
migration batch and service rollout. Failed or uncertain migrations block service
submission and require review, not database rollback or forced replay.

Verify the exact backend source and both intended image digests, API health and
storefront `/gb` three consecutive times, plus successful Nomad deployment health.
Resume only this task's acknowledged worker drain after healthy rollout. A
published image or GitOps commit alone is not deployment success.

## Submitted promotion

At 2026-11-08T18:47:15.9918732Z the manifest and live endpoints agreed. Actual rollback source:
ddad9aa8339fb284b4a86582347f8d021655284a, image ghcr.io/craigbanach/tcg-store-backend@sha256:ccdf43a77bc465a9e570081ead7962e26a819e850626084fc17e5d9c962d56a2. New backend:
ghcr.io/craigbanach/tcg-store-backend@sha256:18e3f7861fcd311fa6264b245b6c5a1862a4bd4cb247ed9d853b14e6dfa768d3. The live source is an ancestor of the selected source; no source
rollback is performed. Storefront and runtime flags are preserved. This task's
worker drain acknowledged zero active jobs. Final rollout verification is pending.
