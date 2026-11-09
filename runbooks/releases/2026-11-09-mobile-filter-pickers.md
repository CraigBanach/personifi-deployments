# One-off mobile filter picker release - 9 November 2026

## Approval and scope

The operator approved the established one-off manual GitOps process. This is a
storefront-only exception, not a change to the normal protected workflow policy.
Frozen application main source: 0388794d9fcbf554557c9bfa743703a5f2ed87d9. The diff from the live storefront consists
only of eight filter/category implementation files and three browser test files.
No finance, backend, dependency or Dockerfile changes are shipped in this image.
No chat is enabled. No payments, carts, orders, subscriptions, emails, catalog
mutation or store configuration application are authorized by this deployment.

The first promotion preflight stopped without writes because a separately
approved backend-only release completed while validation was queued. Its audit is
runbooks/releases/2026-11-09-ebay-order-inventory-release.md. The storefront digest
remained unchanged. Review confirmed no changes between the frozen source and
the new backend source under Store APIs, catalog-facets, API middleware, storefront
or shared dependency manifests. The new backend and its migration receipt are
preserved; runtime-after-concurrent-release.json is the fresh runtime baseline.

## Immutable artifacts and validation

- New storefront: ghcr.io/craigbanach/tcg-store-storefront@sha256:679771c569bc46746d2a33398cdde9dd519604dcd43b73052ce92dbffc8c0004
- Previous storefront/rollback: ghcr.io/craigbanach/tcg-store-storefront@sha256:cfddf8b5eb576a67fc2ae368e09ec02154aa525d72891c3996cad36236270aae
- Preserved backend: ghcr.io/craigbanach/tcg-store-backend@sha256:5c9f69e92a8de42795c54ba491ea37ab4b686308442f2203d390ee2f4e64f981, source fb13b7cc93d5bcb2f1fb7f4f70f6e21c44a18aec
- Canonical LF source archive SHA-256: 2e8ca50716e07a1dcd9b207a39d87b1df515a8d885d29a6ff46bf61a4c73f90d
- Frozen validation workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a
- Isolated Linux validation: 2026-11-09T16:59:26Z through 2026-11-09T17:27:57Z.
- All six validation phases passed; 4475 backend unit tests;
  browser passes: 105 read-only and
  38 stateful, zero unexpected/flaky results.
- Stock-safety inventory: Multichannel proof: 630 passed exactly once (457 standard, 173 recovery); 2 TODOs.
- Retained root-owned evidence: /srv/freesplash-ci/admin/benchmark-20261109T165846Z.

The exact archive was also built with the tracked production Dockerfile for
Linux/amd64, including compilation, lint and type checks. The published digest
was pulled and started non-root with networking disabled and a read-only
filesystem. Runtime SHA/digest and Stripe/PostHog public configuration matched.
No production secrets entered the validation VM. No GitHub Actions used.

## Promotion and rollback controls

Public endpoints and the current manifest agreed before promotion. The backend
and Redis container identities/start times and the backend migration receipt
were read back and preserved. Managed rollout remains enabled; config and catalog
application remain false. Only the storefront digest and release metadata change.
Backend/Redis restart and migration execution are not part of this release.

After reconciliation require twelve consecutive uncached checks of both exact
image identities, API health and the /gb business page. Then use a read-only
mobile browser to verify the actual filter flow, and recheck preserved backend/
Redis containers and migration receipt. Public rollout verification is pending.

If rollback is required, use a new GitOps commit restoring only the previous
storefront digest and appropriate metadata. Never reset the database, hot-patch
containers or overwrite a concurrent operator's release.

## Verified live outcome

Promotion commit: 2638615c7a404a6d8b13bb870534a24b93cdfd16.
At 2026-11-09T17:34:50.845Z, twelve consecutive uncached checks verified the
exact new storefront source/digest, preserved backend source/digest, backend
health and storefront /gb response, all HTTP 200.

Read-only production browser verification passed at 2026-11-09T17:33:52.080Z
at 384x694, 360x640 and desktop 1440x1000: all filter types discoverable;
searchable dedicated set picker without nested scrolling; set persisted through
price submission; rarity/finish accessible; live result count; clear-all;
Escape/focus restoration; footer clear of filter headings; desktop sidebar
retained. No page errors and no non-GET/HEAD requests sent; one such request was
blocked by the read-only browser harness. Screenshots and JSON evidence retained
in the operator's mobile-filters-release-20261109 directory.

Post-rollout runtime inspection confirmed the backend and Redis container IDs,
start times and restart counts are unchanged from the fresh prepromotion baseline;
the migration receipt is unchanged. Chat remains outside the release and disabled
in production. No backend restart, migrations or business-data writes were
performed by this storefront release.
