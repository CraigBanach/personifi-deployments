# One-off backend release - eBay creations vs a moving account export; Click & Drop label retry

## Approval and exact-source validation

On 13 November 2026 the operator asked for the singles fix to be released with the one-off process and chose to release it together with another session's Click & Drop commit ("1" to "Release both together") while GitHub Actions jobs are not starting (billing/spending-limit annotation). Pinned main source: e84fa69e90240a466e4a23c92d5fe39646fb5fc4, which is the live backend e23b4e2311958a50a26205cbfdb4f6c20126578b plus exactly two commits (c5d93f8e, e84fa69e). No Actions workflow, assertion, retry policy or release gate is changed.

Full isolated Linux validation passed from 2026-11-13T12:10:38Z to 2026-11-13T12:40:01Z, all six phases successful. Backend units: 4567 passed, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Retained evidence: /srv/freesplash-ci/admin/benchmark-20261113T120959Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:0648f93c04001aaee3461f449d843c4f1c8324a65cc025faad21c3df5aefcaed
- Validation/build archive SHA-256: eac0820d0acbbc6c54a33cb9ec26d96dca5049432923c6a01643186b15a1be13
- Previous backend/application rollback target: e23b4e2311958a50a26205cbfdb4f6c20126578b, ghcr.io/craigbanach/tcg-store-backend@sha256:99bd778bf6090b6e9940ae983c82e4797a248537468192ac679806ac8ffa19ab
- Retained storefront: 69ff1a30fe166e5aabdd824d8728a234bd1983b6, ghcr.io/craigbanach/tcg-store-storefront@sha256:26025559da79361d57f7b203d0359fedea6094ec7a20b9308386a9ce25fc772d

Changes: (1) e84fa69e: each eBay creation reads the account-wide seller export (GetMyeBaySelling) once per product instead of before and after every step; the export re-reads up to 3 times when a total changes, a page is short or an item repeats, and otherwise returns the union seen (HTTP/envelope/parse failures still fail closed); export cap 3000 -> 30000. Lifecycle and evidence checks now record their fixed reason on a stopped creation. The Channels page Settle action can adopt a creation whose publish eBay acknowledged with an item ID, after verifying that exact item is live. (2) c5d93f8e: an unexpected (non-refusal) error recording a printed Cardmarket label is logged and retried for up to five passes instead of parking the Click & Drop row in review. No migration. Application rollback to e23b4e23 is safe (no schema or data shape change). The packaged image passed network-disabled, read-only execution as UID 1000 (moving export retried, HTTP failure still fails closed, acknowledged publish adoptable only with an item ID, stop reason recorded, one export per product, Click & Drop label retry present, eBay stock channel rule still wired).

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, then resume only this task's nonce. The previous immutable backend is the application-only rollback target.

Submitted at 2026-11-13T12:40:28.319Z. Verified rollout remains pending; image publication or manifest push alone is not success.
