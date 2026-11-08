# One-off corrected-finish recovery backend — 8 November 2026

## Approval and release scope

The operator requested implementing the audited one-use recovery path, refreshing
evidence, recovering Hall of Triumph first, then proceeding only on independent
verification. Reuse the explicitly approved one-off non-GHA build/validation and
GitOps promotion method. This does not replace the normal protected workflow.

- Application main SHA: `7296a1d58e712bcf86edc3fe1ed1e96053a202c9`.
- New backend: `ghcr.io/craigbanach/tcg-store-backend@sha256:de562b91acae77f0390a43da8dfdbecb620e198c44b162b3031d2f3c6aa5c545`.
- Previous backend: `ghcr.io/craigbanach/tcg-store-backend@sha256:4d64989cd6a9920eface8b303b3c03689d12e077b4258c6edd821a7540b8ebfd`.
- Preserve storefront `ghcr.io/craigbanach/tcg-store-storefront@sha256:cfddf8b5eb576a67fc2ae368e09ec02154aa525d72891c3996cad36236270aae`.
- Preserve runtime settings, credentials, probe correction, managed rollout,
  `RUN_CONFIG=false` and `RUN_CATALOG=false`. No marketing send or feature activation.
- Source includes intervening gated purchasing evidence/Admin changes and the
  exact Zero-closure reconciliation fix. Three new migrations: immutable recovery
  admission and two gated purchasing evidence/receipt migrations. Full frozen
  source validation covers fresh migrations and the multichannel safety proof.

## Immutable artifact and full validation

Source archive SHA-256: `7168f1c6941525e2bb6801fdbc7e1baae5593eb200a1a4120b0510a6233377f1`.
Frozen Validate workflow SHA-256: `7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a`.
Build/validation archives match; only tracked exact-SHA source was used.

All six isolated Linux phases passed, 17:24:18–17:52:04 UTC: install, source,
local-stack, proof-standard, proof-recovery, proof-inventory.

- 4,070 backend unit passes; zero failures; 47 existing opt-in/pending and 4 TODO.
- 618 multichannel cases passed exactly once: 445 standard, 173 recovery; two TODOs.
- 101 read-only browser passes; 37 first-attempt stateful passes and one stateful
  pass on configured retry. No final browser failures. The retried pre-existing
  `delivery, manual test payment and review fit at 1440px` test initially observed
  the basket accessible name as empty; it passed on retry. This caveat is retained,
  not reported as a first-attempt pass. No storefront image is rebuilt/promoted.
- Two conditional browser skips: unconfigured Stripe payment and optional
  authenticated eBay Admin test. Actual price-edit runtime proof passed.
- Fresh migrations/builds, SQL/email/marketing proofs, lint and types passed.
- Dedicated local disposable PostgreSQL proof: 47 passes, including both Magic
  foil and Pokémon reverse-holo recovery, concurrent approvals, expiry, mutation
  guards, stale/partial/foreign/sale/positive-stock proof rejection, current
  reservation/price checks and independent exact-quantity binding; 30 focused
  worker/listing unit passes and TypeScript check also passed.
- Root-owned evidence: `/srv/freesplash-ci/admin/benchmark-20261108T172338Z`.
  VM destroyed after collection. Local evidence retained in the approved operator
  temporary directory `backend-recovery-release-20261108`.
- Network-disabled, read-only, non-root image inspection confirmed exact source,
  compiled explicit admission/claim revalidation/exact binding, migration and
  operator script. An earlier stdin-based diagnostic timed out; its isolated
  container was stopped and replaced by the successful direct-command inspection.

## Safety and pending operational recovery

The one-use admission is not a fence reset. A unique original attempt buys one
immutable job with a ten-minute expiry. Original evidence remains frozen; queued
evidence is checked again at claim. Failed/expired jobs cannot replay or renew.
Publication requires independent exact finish, quantity, price and binding.

Fresh 35-item census/order reconciliation completed 17:46:41 UTC: all absent,
unbound, no historical order matches. Census 17:40:22 UTC: 303 pages / 3,766 articles
/ 5,944 units. Complete all-status reads before and after each found eight orders.
Hall's corrected-foil preview `chcmjob_01M6Y4AHZFYE0RSEX1EY38RGXT` passed at 17:49:14 UTC.
These timestamps are evidence, not permission to extend freshness limits.

Worker drain was requested and then confirmed with zero active jobs before
promotion. The task-specific matching nonce must be resumed only after exact
live backend/storefront digests and health are verified. No original attempt or
manual ordinary recovery pause has been cleared. No live retry yet.

Managed migrations must finish before service submission. Do not roll back the
database or reset an uncertain migration. Require three consecutive public
backend/storefront identity, API-health and `/gb` checks; inspect the live recovery
table/guards before any operational admission. Record deployment and recovery
outcomes separately below.

Status: validated; promotion and live recovery verification pending.
