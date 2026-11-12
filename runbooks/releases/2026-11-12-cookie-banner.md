# One-off cookie banner storefront release - 12 November 2026

## Approval and scope

The operator approved the established one-off manual GitOps process. This is a
storefront-only exception, not a change to the normal protected workflow policy.
Frozen application main source: 69ff1a30fe166e5aabdd824d8728a234bd1983b6. The operator chose to ship all of main's
storefront delta from the live storefront (245313fd): a shorter single-choice
cookie banner (Allow also grants Google Ads ad_user_data; the separate checkbox
is removed), homepage view-all sort order, address dialogs closing on save,
checkout clicks kept while the basket updates, and the sell-your-cards price
guide. No finance, backend, dependency or Dockerfile changes are shipped in this
image. No payments, carts, orders, subscriptions, emails, catalog mutation or
store configuration application are authorized by this deployment.

GitHub Actions remains blocked by billing, so this release follows the one-off
local validation/build and GitOps route. The live backend (8882e4a9, audit
runbooks/releases/2026-11-12-click-and-drop-europe-rules.md), Redis runtime and
migration receipt are preserved against the runtime-before.json baseline.

## Immutable artifacts and validation

- New storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:26025559da79361d57f7b203d0359fedea6094ec7a20b9308386a9ce25fc772d
- Previous storefront/rollback: ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2
- Preserved backend: ghcr.io/craigbanach/tcg-store-backend@sha256:0af2af8ef81409e345efe2ff03522239e4b848bd6fad452b2723f585c0db78e5, source 8882e4a980715a465032a01db86c45b4ab650e51
- Canonical LF source archive SHA-256: ae72ee47eab9a76331504a1942a4c0b322970a5b51516fb50a6751c1567d75c5
- Frozen validation workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a
- Isolated Linux validation: 2026-11-12T15:14:53Z through 2026-11-12T15:44:27Z.
- All six validation phases passed; 4554 backend unit tests;
  browser passes: 105 read-only and
  38 stateful, zero unexpected/flaky results.
- Stock-safety inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs.
- Retained root-owned evidence: /srv/freesplash-ci/admin/benchmark-20261112T151412Z.

The exact archive was also built with the tracked production Dockerfile for
Linux/amd64, including compilation, lint and type checks. The published digest
was pulled and started non-root with networking disabled and a read-only
filesystem. Runtime SHA/digest and Stripe/PostHog public configuration matched.
No production secrets entered the validation VM. Release validation and image
building were local, not GitHub Actions; the earlier failed dispatch is not used
as validation evidence.

## Promotion and rollback controls

Public endpoints and the current manifest agreed before promotion. The backend
and Redis container identities/start times and the backend migration receipt
were read back and preserved. Managed rollout remains enabled; config and catalog
application remain false. Only the storefront digest and release metadata change.
Backend/Redis restart and migration execution are not part of this release.

After reconciliation require twelve consecutive uncached checks of both exact
image identities, API health and the /gb business page. Then use a read-only
browser to verify the cookie banner, and recheck preserved backend/
Redis containers and migration receipt. Public rollout verification is pending.

If rollback is required, use a new GitOps commit restoring only the previous
storefront digest and appropriate metadata. Never reset the database, hot-patch
containers or overwrite a concurrent operator's release.