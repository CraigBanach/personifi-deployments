# One-off backend release - Cardmarket Standard Large Letter

## Operator approval and exact-source validation

On 10 November 2026 the operator requested the existing one-off deployment process and initially waived validation, then explicitly requested validation before promotion. Full isolated Linux validation passed for the exact pinned main source from 2026-11-10T10:50:24Z to 2026-11-10T11:20:54Z. All six phases passed; backend unit tests: 4711 passed, zero failed. Browser results: 105 read-only passes and 36 stateful passes, zero unresolved failures. Retry policy: Repository retries=1 unchanged. Two reviewed purchase-surfaces checkout-navigation timeouts passed retry 1; these remain reported as flaky results, not first-pass successes.. Evidence: /srv/freesplash-ci/admin/benchmark-20261110T104945Z. Stock-safety inventory: Multichannel proof: 632 passed exactly once (459 standard, 173 recovery); 2 TODOs.. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Validation and build source archive hashes match. Packaged mapping and guards were inspected network-disabled/read-only as UID 1000. No GitHub Actions was dispatched. The normal workflow is unchanged.

## Pinned release scope

- Main source: 54234d5638eaf010239f4f8a1f2513e06abc84b7
- New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:877b6ac328fcde2c7dede7f5a982bb30048fc48a63b0892d0cee2fc0fdb60fb4
- Canonical source archive SHA-256: 706a03c31fa726730dec94166977df33cdafdab05b5d09c8557d4ead9201306a
- Previous backend source: fb13b7cc93d5bcb2f1fb7f4f70f6e21c44a18aec
- Previous backend image: ghcr.io/craigbanach/tcg-store-backend@sha256:5c9f69e92a8de42795c54ba491ea37ab4b686308442f2203d390ee2f4e64f981
- Preserved storefront source: 0388794d9fcbf554557c9bfa743703a5f2ed87d9
- Preserved storefront image: ghcr.io/craigbanach/tcg-store-storefront@sha256:679771c569bc46746d2a33398cdde9dd519604dcd43b73052ce92dbffc8c0004

Adds the exact UK Standard Large Letter (2nd Class) mapping, including the observed (Online) variant, to OLP2/largeLetter without tracking. Unknown methods, unavailable services/formats and oversized parcels remain blocked. This pinned main also contains committed Cardmarket worker and purchasing observation changes since the previous live backend, including Migration20261109223017. No unrelated dirty-worktree files are included.

## Managed rollout and recovery

Task-owned Cardmarket drain acknowledged zero active jobs before submission. Existing serialized GitOps migration and Nomad rollout remain enabled. Config/catalog apply, credentials, feature gates and storefront digest are unchanged. No order retry, postage purchase, dispatch, stock edit or marketplace replay is authorized or performed by this release. Separately, at the operator's request, FS142's existing review record now displays manual handwritten-label/Post Office postage instructions, with physical handover still unconfirmed; it remains excluded from automatic postage retries.

Failed or uncertain migration blocks service submission and requires inspection; no automatic database rollback. The previous immutable backend above is the application rollback target, not a database rollback. Preserve the task drain until public backend source/digest, unchanged storefront source/digest, API health and storefront /gb pass three consecutive checks and Nomad is healthy. Do not take over another task's drain.

## Submitted promotion

Submitted at 2026-11-10T11:22:06.3046614Z. Healthy rollout verification pending; image publication and manifest push alone are not success.