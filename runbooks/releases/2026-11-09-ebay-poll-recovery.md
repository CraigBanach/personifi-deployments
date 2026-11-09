# One-off approved main promotion: eBay interrupted-poll recovery

The operator explicitly requested the established one-off process after GitHub
Actions rejected promotion 42607935677 before startup because of account billing.
Source is published main `7d297714818b99cfb25738cf3036e3a820dcf6cc`, not a
feature-branch substitute or a selective live-source release. It includes main's
other committed backend changes; the operator explicitly chose actual main.
This retry pins actual published main after the Linux zero-offset fix. The first Linux gate failed on GMT+0 and retained one browser retry; it was not promoted. All six phases must pass again on this source.

## Validation gate — PASSED

Full isolated exact-SHA Linux validation passed from 2026-11-09T12:16:42Z to 2026-11-09T12:45:25Z. Archive SHA-256: 83217e47b7c1ca80221bd192811c93c235f455d7e70ee3271d5e068515f2f8da. All six phases passed; 4455 backend tests; stock-safety inventory: Multichannel proof: 620 passed exactly once (447 standard, 173 recovery); 2 TODOs.. Browser passes: 101 read-only and 37 stateful, zero unresolved failures; 1 configured retry in the unchanged 320px address test, passed on retry 1. All tests remained enabled; retries=1 is the repository Playwright policy. Evidence: /srv/freesplash-ci/admin/benchmark-20261109T121604Z. Packaged backend verified network-disabled/read-only as UID 1000. GitHub promotion 42607935677 failed before jobs started; this one-off run used no additional GitHub Actions.

## Managed rollout

Only the backend digest and release metadata change. Preserve the current
storefront digest, managed migrations, catalog/config switches and all runtime
settings. Obtain a task-owned Cardmarket worker drain acknowledging zero active
jobs before promotion; retain that nonce for resume after successful rollout.
The ordinary serialized GitOps migration/service rollout is used, not container
replacement or direct production SQL patches.

Public exact backend/storefront release identities and both health endpoints
must pass three consecutive checks. Then resume this task's worker drain and
verify normal native eBay polling clears the interrupted scan, followed by the
ordinary daily creation batch. No bulk listing replay, allowance change, order
reclassification or stock-safety bypass is authorized.

Rollback is the previous backend digest with the storefront unchanged, only
after reviewing migration compatibility. Do not automatically roll back schema
or retry an uncertain migration. See the previous manifest and retained
promotion-before.json for exact rollback identity.

## Submitted promotion

At 2026-11-09T12:46:53.2324251Z the manifest and public endpoints agreed. Previous backend: 28f97860cf6386cdc9783724b31dfbc8bf110328, ghcr.io/craigbanach/tcg-store-backend@sha256:b492abbfe8f5ca0cec15f0c27dd08b28b848a5d42825942e410f98f81e1b4b5d. New backend: ghcr.io/craigbanach/tcg-store-backend@sha256:a14586c44a6b9905aef2bed652e7b637999a2f77c08ee51bcfd1cc87d904afdd. Storefront and runtime flags preserved. Task-owned drain acknowledged zero active jobs. Final public rollout verification pending.

## Live rollout verified

At 12:50:50 UTC all four public endpoints passed three consecutive checks:
backend `/release` reported source `7d297714818b99cfb25738cf3036e3a820dcf6cc`
and digest `sha256:a14586c44a6b9905aef2bed652e7b637999a2f77c08ee51bcfd1cc87d904afdd`;
storefront `/api/release` retained source `ff0e3d1715ff5319218074ef2ef71bca5e487e12`
and digest `sha256:cfddf8b5eb576a67fc2ae368e09ec02154aa525d72891c3996cad36236270aae`.
API `/health` and storefront `/gb` returned HTTP 200. The task-owned Cardmarket
drain was resumed, with `draining=false` and zero active jobs at acknowledgement.
Normal eBay source-poll and daily creation readback is tracked separately.

## Normal eBay recovery verified

- The normal source poll at 12:52 re-read the interrupted window and retired
  `chscan_01M6VE3ZEBX6G1WJKR6ZMS2DA9` as failed at 12:52:05.806 UTC.
  No direct SQL repair, source timestamp extension or readiness bypass was used.
- The 13:00 hourly run admitted today's batch at 13:01:11 UTC: budget 11,
  11 selected. By 13:18:54 UTC, **10 creations completed** with provider listing
  IDs and **all 10 had exact native stock coverage** on independent SQL readback.
- One creation remains uncertain for explicit review:
  `chebayop_01M706C805CW8HBY1RJJAMB7M4`, SKU `MTG-LTR-SBB-EN`.
  Inventory and offer acknowledgements are retained (offer `351068276011`);
  publication stopped at `after_start_evidence`, category `guard`. It was not
  replayed or represented as a successful listing. Its ordinary incomplete-batch
  watchdog remains applicable; any reconciliation needs fresh reviewed evidence.
- The new watchdog emitted a successfully persisted Admin feed notification at
  13:00 for `daily_batch_missing` before that hourly batch was admitted. This
  verifies actual alert delivery, not only code registration. The notification
  is historical; the daily batch subsequently progressed normally.
- Readback artifacts: `ebay-batch-settled-readback.json`,
  `live-health-verified.json`, `worker-resume-result.json` under the approved
  local release directory `ebay-poll-release-20261109-r2`.
