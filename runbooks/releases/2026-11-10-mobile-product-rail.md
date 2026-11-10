# One-off mobile product rail release - 10 November 2026

## Approval and scope

The operator approved the established one-off manual GitOps process. This is a
storefront-only exception, not a change to the normal protected workflow policy.
Frozen application main source: 245313fdf88b730f491fa3b97f60835aad28f96f. The diff from the live storefront consists
only of the homepage product rail and its browser regression test. Explicit
overflow-y-hidden prevents vertical swipes being caught by the horizontal rail.
No finance, backend, dependency or Dockerfile changes are shipped in this image.
No chat is enabled. No payments, carts, orders, subscriptions, emails, catalog
mutation or store configuration application are authorized by this deployment.

The normal Actions validation attempt failed before worker allocation and did
not deploy anything. This release follows the explicitly requested one-off
local validation/build and GitOps route used for the previous storefront release.
The first promotion preflight stopped without writes because the separately
approved Cardmarket Large Letter backend release completed during validation.
Its audit is runbooks/releases/2026-11-10-cardmarket-large-letter.md. Its source
54234d5638eaf010239f4f8a1f2513e06abc84b7 differs from this fully validated source
only in the two storefront files listed above: backend and shared inputs match.
The new backend image, Redis runtime and migration receipt are preserved against
the fresh runtime-after-concurrent-release.json baseline.

## Immutable artifacts and validation

- New storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2
- Previous storefront/rollback: ghcr.io/craigbanach/tcg-store-storefront@sha256:679771c569bc46746d2a33398cdde9dd519604dcd43b73052ce92dbffc8c0004
- Preserved backend: ghcr.io/craigbanach/tcg-store-backend@sha256:877b6ac328fcde2c7dede7f5a982bb30048fc48a63b0892d0cee2fc0fdb60fb4, source 54234d5638eaf010239f4f8a1f2513e06abc84b7
- Canonical LF source archive SHA-256: b0ad187cddbb33637bfa384900156895b4f390ee937b7474a7c68c251c8c5aa2
- Frozen validation workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a
- Isolated Linux validation: 2026-11-10T11:21:36Z through 2026-11-10T11:50:13Z.
- All six validation phases passed; 4711 backend unit tests;
  browser passes: 105 read-only and
  38 stateful, zero unexpected/flaky results.
- Stock-safety inventory: Multichannel proof: 632 passed exactly once (459 standard, 173 recovery); 2 TODOs.
- Retained root-owned evidence: /srv/freesplash-ci/admin/benchmark-20261110T112058Z.

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
mobile browser to verify the actual product rail gestures, and recheck preserved backend/
Redis containers and migration receipt. Public rollout verification is pending.

If rollback is required, use a new GitOps commit restoring only the previous
storefront digest and appropriate metadata. Never reset the database, hot-patch
containers or overwrite a concurrent operator's release.

## Verified live outcome

Promotion commit: `28e826f`. At 2026-11-10T11:56:04.030Z twelve consecutive
uncached checks verified the intended storefront source/digest, preserved backend
source/digest, backend health and storefront `/gb`, all HTTP 200.

Read-only mobile Chromium touch verification passed at 2026-11-10T11:56:32.693Z
at widths 390 and 360: vertical swipes moved the page 135px while rail scrollTop
remained zero; horizontal swipes moved the rail 203px. Computed overflow-y was
hidden. No page errors occurred. All non-GET/HEAD requests were blocked; no
production business writes were performed. Screenshots and JSON evidence are
retained in the operator's `mobile-rail-release-20261110` directory.

Post-rollout runtime inspection confirmed the backend and Redis container IDs,
start times and restart counts match the fresh prepromotion baseline; both remain
running. The migration receipt is unchanged. No backend restart, migration or
business-data mutation was performed by this storefront release.
