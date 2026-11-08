# One-off main/backend release — campaign catalogue selections

## Approval and pinned scope

The operator explicitly requested publishing all pending main work and using the
previous one-off non-GHA deployment process. This exception is release-specific;
it does not replace the normal protected workflow.

- Frozen main source: `ddad9aa8339fb284b4a86582347f8d021655284a`.
- Canonical LF source archive SHA-256:
  `518931fa9ce12ded7564a9151fc19c5fdd7e375a5ea9b7843fbaa47469dac4bc`.
- Current backend/rollback source: `f43ca218b96b59a35763d2c1384a87c47e23be6d`;
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
