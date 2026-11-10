# One-off backend release - Admin Actions and compact Cardmarket

## Operator approval and validation

On 10 November 2026 the operator explicitly requested deployment using the existing one-off process. No GitHub Actions run was dispatched and the normal workflow remains unchanged. Full isolated Linux validation of the exact pinned main SHA passed from 2026-11-10T12:57:18Z to 2026-11-10T13:26:01Z. All six phases passed. Backend units: 4740 passed, zero failed. Browser passes: 105 read-only and 38 stateful; zero unexpected or flaky outcomes. Evidence: /srv/freesplash-ci/admin/benchmark-20261110T125639Z. Workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Source archive hashes match validation and image build. Stock-safety inventory: Multichannel proof: 632 passed exactly once (459 standard, 173 recovery); 2 TODOs..

The packaged image was inspected network-disabled/read-only as UID 1000. It contains the seven read-only Actions sources, authenticated API, historical sold-article diagnostics, Admin route and topbar shortcut. Local desktop/mobile fixture browser checks and 51 focused tests also passed.

## Immutable release scope

- Main source: 0742bab6697a913c03d04ffb8761515681b95724
- New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:963d12808408ba710f66f4b81d211c940cb8b9523ef36477034293e39bebcb41
- Canonical source archive SHA-256: bb6672cd17170546972d857a46bb12464d553824aa9cbc5e3bcc5b18d81ea473
- Previous backend: 54234d5638eaf010239f4f8a1f2513e06abc84b7, ghcr.io/craigbanach/tcg-store-backend@sha256:877b6ac328fcde2c7dede7f5a982bb30048fc48a63b0892d0cee2fc0fdb60fb4
- Preserved storefront: 245313fdf88b730f491fa3b97f60835aad28f96f, ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2

Only the task's 13 backend/Admin source and test files differ from the previous backend source. No migrations were added. Adds the central Actions inbox and exact order blockers, moves daily Cardmarket orders ahead of matching, listing, worker and settings controls, removes empty inactive channel panels, and preserves normal marketplace protocols.

## Managed rollout and recovery

The task-owned Cardmarket drain acknowledged zero active jobs before submission. Serialized GitOps migrations and Nomad rollout remain enabled. Config/catalog apply flags, credentials, feature gates, data-mutation flags and the storefront digest are preserved. This release performs no order replay, postage purchase, dispatch, physical-stock change or catalogue mutation. The earlier owner-confirmed order import was a separate recorded operation.

Failed or uncertain migration blocks service rollout and requires inspection; no automatic database rollback is attempted. The previous immutable backend above is the application rollback target, not a database rollback. Preserve the task drain until backend source/digest, unchanged storefront source/digest, API health and storefront /gb pass three consecutive checks and Nomad is healthy. Resume only this task's maintenance nonce; never take over another drain.

## Submitted promotion

Submitted at 2026-11-10T13:27:51.5326549Z. Healthy rollout verification pending; image publication and manifest push alone are not success.