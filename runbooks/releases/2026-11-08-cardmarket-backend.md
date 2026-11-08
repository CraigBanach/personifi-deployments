# One-off backend release — 8 November 2026

## Approval and scope

The operator explicitly requested deployment using the existing one-off non-GitHub-Actions method. This is a release-specific exception, not a change to the normal protected workflow.

- Application main SHA: `f43ca218b96b59a35763d2c1384a87c47e23be6d`.
- Backend image: `ghcr.io/craigbanach/tcg-store-backend@sha256:4d64989cd6a9920eface8b303b3c03689d12e077b4258c6edd821a7540b8ebfd`.
- Previous backend: `ghcr.io/craigbanach/tcg-store-backend@sha256:04710fc8ae9619413c508dc2d53ea2264e03244a675c0e480512c614ad7f5687`, source `c44fdd074569e78eb0bf868eb58128bcd5295a80`.
- Preserve storefront digest `sha256:cfddf8b5eb576a67fc2ae368e09ec02154aa525d72891c3996cad36236270aae`, its probe correction, all credentials and runtime settings.
- Keep managed rollout enabled and config/catalog application disabled.
- Newer main changes are excluded. The chosen source includes gated bundle/purchasing work and four additive bundle evidence/authority migrations; full frozen-source validation includes fresh migrations and stock-safety proofs.
- The backend includes SortSwift finish preservation, verified catalogue routes and permanent unresolved-submission fences. No original attempt reset, recovery admission, listing replay, vacation change, marketing send or feature activation is authorized by deployment.
- The outstanding dispatch UI/PDF redesign is not claimed complete by this release.

## Exact-source verification

Canonical source archive SHA-256: `15666e363b2cb609d68d8ce1cff6624e963db4935a690a0a5691939c9d01f614`.
Frozen Validate workflow SHA-256: `7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a`.

Full isolated Linux validation completed 16:17:45–16:44:05 UTC. All six phases exited zero: install, source, local-stack, proof-standard, proof-recovery, proof-inventory.

- Backend units: 3,896 passed; zero failed; 25 existing pending / 4 TODO.
- Multichannel: 617 non-TODO cases passed exactly once, 445 standard and 172 recovery; two existing TODOs.
- Browser: 101 read-only and 38 stateful passes; no failures or flaky cases. Two existing conditional skips: unconfigured Stripe payment and optional authenticated eBay Admin test.
- Fresh database migrations, backend/Admin and storefront builds, SQL/email/marketing proofs, lint and types passed. No live payment or email tests were run.
- VM isolation/lifecycle guard was reused; guest destroyed after collecting root-owned evidence at `/srv/freesplash-ci/admin/benchmark-20261108T161705Z`.
- Local evidence: `backend-manual-release-20261108` in the approved operator temp directory; build and validation archive checksums match.
- Network-disabled, read-only, capability-dropped image inspection confirmed non-root UID 1000, exact source SHA, compiled finish preservation/catalogue routes and both permanent fences.

## Rollout and recovery

Cardmarket maintenance drain acknowledged zero active jobs before promotion. Retain its task-specific nonce until healthy deployment and worker resumption; never take over another maintenance request.

Use the existing serialized GitOps managed migration batch and rollout. A migration failure must prevent service submission. Do not reset migrations or perform automatic database rollback. Any uncertain migration requires operator inspection; an application rollback is not a database rollback.

Promotion is not complete until both public release digests, API health and storefront `/gb` pass at least three consecutive checks, the live backend reports the exact source, and the compiled fixes and unchanged 35 verification-pending attempts are checked. Preserve the storefront image throughout.

Status: validated artifact; promotion/public verification pending.
