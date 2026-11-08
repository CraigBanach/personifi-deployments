# One-off main/backend release — campaign catalogue selections

## Approval and pinned scope

The operator explicitly requested publishing all pending main work and using the
previous one-off non-GHA deployment process. This exception is release-specific;
it does not replace the normal protected workflow.

- Frozen main source: `ddad9aa8339fb284b4a86582347f8d021655284a`.
- Canonical LF source archive SHA-256:
  `518931fa9ce12ded7564a9151fc19c5fdd7e375a5ea9b7843fbaa47469dac4bc`.
- Initially observed backend source (superseded by the preceding main release): `f43ca218b96b59a35763d2c1384a87c47e23be6d`;
  digest `sha256:4d64989cd6a9920eface8b303b3c03689d12e077b4258c6edd821a7540b8ebfd`.
- Preserve storefront source `ff0e3d1715ff5319218074ef2ef71bca5e487e12` and
  digest `sha256:cfddf8b5eb576a67fc2ae368e09ec02154aa525d72891c3996cad36236270aae`.
  No storefront/shared-build-input changes require a rebuild.
- Preserve all credentials, runtime flags and corrected lightweight storefront
  probes. Managed migrations stay enabled; config/catalog application stays off.

This release includes the campaign fix and already committed main work, including
audited purchasing cost acceptance/Admin support and immutable Cardmarket recovery
admission. Deployment does not activate gated workflows, admit/replay marketplace
attempts, create accounting evidence, adjust stock, or send campaigns.

The campaign fix uses fresh anonymous UK/GBP calculated prices, audited exact
catalogue selections, existing stability/quantity rules and an explicit small
arrival exception. Existing Brevo HTML/plain text and attribution IDs are linked
by native-review evidence rather than overwritten by the generic app renderer.
Audience, expiry, suppression, QC, five-minute approval, cross-game holds and
manual send-reconciliation guards remain in force.

## Validation gate — PENDING

The frozen Validate workflow is unchanged from the reviewed mirror, SHA-256
`7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a`.
The full isolated Linux run must pass all six phases, fresh migrations/builds,
SQL/email/marketing/browser checks and both complete stock-safety partitions.
Successful earlier sources and local focused tests are not a substitute.

The first attempt correctly refused the occupied host validation lock. The
pinned run is queued behind that lock without interrupting any other worker.
Image publication is not production promotion. No manifest change may be
committed before the complete matching-source evidence and image proof pass.

## Managed rollout and recovery

After validation, re-read origin/main and the current GitOps manifest to avoid
overwriting another deployment. Confirm the live backend is an ancestor of the
chosen SHA. Drain Cardmarket jobs with a new task-specific maintenance nonce;
require zero active jobs without taking over another session's drain.

Use the existing serialized, bounded managed migration batch. A failed/uncertain
migration must prevent service submission and requires inspection, not reset or
automatic database rollback. Then verify both exact public image digests, backend
source, API health and storefront `/gb` repeatedly, successful Nomad health and
unchanged storefront image. Resume only this task's acknowledged worker drain.

Retain the previous backend image for application recovery; never roll back the
database automatically or erase retained recovery/receipt/campaign evidence.

After healthy release, independently recheck live Brevo #11/#12 state/content;
the saved artifacts are not current provider evidence. Refresh exact products,
native QC and audience before approval/export/send, never repeating an accepted
or ambiguous send. This application rollout itself does not send email.

## Submitted promotion

At 2026-11-08T18:19:47.8466244Z the previous live backend was 7296a1d58e712bcf86edc3fe1ed1e96053a202c9,
image ghcr.io/craigbanach/tcg-store-backend@sha256:de562b91acae77f0390a43da8dfdbecb620e198c44b162b3031d2f3c6aa5c545. The manifest and live endpoints agreed before
promotion. New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:ccdf43a77bc465a9e570081ead7962e26a819e850626084fc17e5d9c962d56a2. The chosen source contains the previous
live source; this is not a source rollback. Storefront image and runtime flags
are preserved. This task's Cardmarket maintenance drain acknowledged zero
active jobs before submission. Final rollout verification is still required.

## Verified live outcome — 18:24 UTC

Promotion commit: `f0cf04b72c482b727b6af4c183f8075bfb262054`.
Nomad deployment `0d24c540` completed successfully, job version 308.
Backend allocation `78ff2537-1f27-5b47-300b-f9cfc206ea86` serves the exact
validated source and new digest. Storefront allocation
`1d3d510e-cc1d-9e2d-293d-42b0f2f00bc2` and its image remain unchanged.

Both public image digests, backend source, API health and storefront `/gb`
passed 12 consecutive uncached checks. Direct read-only inspection confirmed
the five live campaign modules have the same SHA-256 hashes as the packaged
image proof: curation actions, calculated-price reader, release review,
renderer and outcome reporting. No provider calls or database connections were
made by that compiled-source inspection.

At 18:24:43 UTC the matching task-specific maintenance resume acknowledged
`draining=false`, with zero active jobs at that instant. Ordinary worker claims
are resumed; no other session's maintenance request was taken over.

At 18:24:48 UTC fresh anonymous UK/GBP Store API reads verified all six exact
variant prices: Crimson Vow £147.99, Zendikar £164.99, LOTR £314.99, Journey
Together £214.99, Destined Rivals ETB £99.99 and Prismatic Evolutions ETB
£139.99. These reads made no cart, payment, inventory or campaign changes.

The immediately preceding backend/rollback image is
`ghcr.io/craigbanach/tcg-store-backend@sha256:de562b91acae77f0390a43da8dfdbecb620e198c44b162b3031d2f3c6aa5c545`,
source `7296a1d58e712bcf86edc3fe1ed1e96053a202c9`. The earlier f43 image is
historical context, not the immediate rollback target. No schema rollback is
authorized. The campaign delta from the preceding source adds no migrations.

Deployment is complete. No campaign curation, audience export/attachment,
contact membership change, approval or send was performed by this rollout.
Live Brevo state/content and fresh exact product/audience review remain required
before the separately authorized campaign release can proceed.
