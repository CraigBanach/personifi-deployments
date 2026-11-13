# One-off backend release - uncertain eBay listing update no longer blocks later syncs

## Approval and exact-source validation

On 13 November 2026 the operator asked for this fix to be released with the home-server release route while GitHub Actions jobs are not starting (billing/spending-limit annotation). Pinned main source: 85d392175a6965f90c5b778d8d5ae7c2f59883d0, which is the live backend e84fa69e90240a466e4a23c92d5fe39646fb5fc4 plus exactly one commit (85d39217). No Actions workflow, assertion, retry policy or release gate is changed.

Full isolated Linux validation passed from 2026-11-13T18:13:11Z to 2026-11-13T18:42:28Z, all six phases successful. Backend units: 4568 passed, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Retained evidence: /srv/freesplash-ci/admin/benchmark-20261113T181232Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:9c5c92a0d6369656f0311a9bb92061dbf5d788f66d6a4332e45ba0b2b9affd32
- Validation/build archive SHA-256: a827ff04bf079937f4b78e8c40a738b765edabcce778cb63dc2050109fb95a2a
- Previous backend/application rollback target: e84fa69e90240a466e4a23c92d5fe39646fb5fc4, ghcr.io/craigbanach/tcg-store-backend@sha256:0648f93c04001aaee3461f449d843c4f1c8324a65cc025faad21c3df5aefcaed
- Retained storefront: 69ff1a30fe166e5aabdd824d8728a234bd1983b6, ghcr.io/craigbanach/tcg-store-storefront@sha256:26025559da79361d57f7b203d0359fedea6094ec7a20b9308386a9ce25fc772d

Change: an eBay listing update of a live listing that ended uncertain no longer excludes later writers (evidence ownership, journal admission and the stock-attempt writer). Each later writer re-reads eBay and writes the full desired state, so a retry converges. Uncertain creations and withdrawals, deleted operations and admitted (running) updates still block. Trigger: a Crimson Vow draft booster box price update stopped before any provider effect on 12 Nov (moving seller export) and blocked that listing's price and stock sync. No migration. Application rollback to e84fa69e is safe (no schema or data shape change). The packaged image passed network-disabled, read-only execution as UID 1000 (predicate cases, SQL shape, all three call sites wired, previous release fixes still present).

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, then resume only this task's nonce. The previous immutable backend is the application-only rollback target.

Submitted at 2026-11-13T18:42:54.490Z. Verified rollout remains pending; image publication or manifest push alone is not success.
