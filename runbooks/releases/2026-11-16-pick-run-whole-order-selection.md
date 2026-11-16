# One-off release: whole-order pick selection

Operator requested deployment through the existing one-off process on 16 November 2026. Hosted Actions remain blocked by the billing/spending annotation retained on run 43622459532. No workflow or safety gate changed.

## Exact source and full validation

Source: 56b79d8fed9ad5eb9e8ba4e1386bd79e26a6c314, reachable from main. Exactly nine backend/Admin files differ from live 182cd9cc38ef7ce5f419021779aa72a404e53731; no storefront, dependencies, schema, secrets, settings or catalog changes. Immutable archive SHA-256: 2d3ca9ce62d13a85c61f191961f5dc1b0424cc8ebc33e33748e7accb15d6827c.

Full isolated Linux validation passed 2026-11-16T12:17:56Z to 2026-11-16T12:47:48Z. All six phases passed, including source lint/unit/typechecks, fresh migrations and application builds, SQL/email/marketing integration, full browser coverage and both multichannel proof partitions with exhaustive inventory. Backend units: 4638, zero failed. Browsers: 105 read-only and 38 stateful, zero unexpected/flaky. Workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261116T121714Z; local copy in pick-run-release-20261116. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs.

## Scope and packaged proof

Production logs identified Initial attachment plugin pick requires all original lines. The UI now links selection across attached orders, explains missing-count controls, and excludes an entire attached order when one line cannot be allocated. POST verifies the full frozen line identity and quantity before ordinary stock/order/event or missing-card writes; final fenced writer checks remain. Missing cards stay part of full pick demand. Packaged image proof runs read-only, network-disabled as UID 1000 and exercises selection, partial/substituted rejection, missing-card/full split demand, and Admin guidance packaging.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:959b768d51a5238a0c016b2c1178bc10b2c220fd9751304ac94385d6324d0ec9

Previous backend/application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:ac5b52b24650b59c4e05c0ddb8aae0466398ebcca8ac7ef177764a82912d5d80 (182cd9cc38ef7ce5f419021779aa72a404e53731). Storefront retained unchanged: ghcr.io/craigbanach/tcg-store-storefront@sha256:0f8e8fbd1d84103d62de62e7c33cd67055dc224d1a4c7b0d4f8f32ef83bcc5ec (182cd9cc38ef7ce5f419021779aa72a404e53731). No new migrations in this change and no production data repair/replay is attempted.

## Guarded managed rollout

The task-owned Cardmarket drain acknowledged zero active jobs. All existing secrets, feature gates and manifest settings are preserved; config/catalog execution remain false. Managed GitOps remains the rollout path. Publishing an image/manifest is not success: require three consecutive uncached checks for exact backend/storefront identities, API health and /gb, then resume only this task's nonce. Application rollback would restore the previous backend digest through GitOps, never reset the database.

Submitted 2026-11-16T12:48:28.658Z. Live verification pending.
