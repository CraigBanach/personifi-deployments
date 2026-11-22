# One-off release: unstick CardNexus, CardTrader and eBay listing writes; cancel not-sent CardTrader Zero batch

On 22 November 2026 the operator asked for the abandoned eBay update fix to be promoted with e1753f3b through the established one-off process ("Do a", then "Get this turned back on" for Best Offer rule repair). Exact main source: d6a5a43bd669b3a8bb9cc544c60604f4c424923e, five commits (e1753f3b CardNexus/CardTrader listing writes, 8417043c cancel a CardTrader Zero batch whose cards were all marked not sent, 673dbdf1 abandoned eBay update settlement, 03784f30 requested eBay price syncs move Best Offer rules with the price, d6a5a43b retry of an update whose earlier attempt ended uncertain gets a fresh operation key) on the live ed18b4ea741b90380f38c8d5847c677a45bd5bf7; this is the whole of origin/main at pin time. Archive SHA-256: 04c7b9102763c55ea476159703f5cb16407be07702a8f07d9a104791b5866c1b. No assertion, retry or release gate is weakened.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-22T19:45:48Z to 2026-11-22T20:18:13Z. Backend units: 4942, zero failed. Browser checks: 104 read-only and 38 stateful, zero unexpected outcomes; one read-only test passed only on retry (brand-styling.spec.ts > mobile > pokemon-151-elite-trainer-box actions use navy and cream), accepted by the operator ("Accept the flake and promote, then fix the flake"); the storefront is unchanged by this release. Workflow SHA-256 32b5377c4a6dfd1f251d35c3d07af7c98f578fc1bf310e6ca6f8013f889d3812. Evidence: /srv/freesplash-ci/admin/benchmark-20261122T194509Z. Proof inventory: Multichannel proof: 635 passed exactly once (462 standard, 173 recovery); 2 TODOs..

## Runtime scope

CardNexus listing writes get their own budget (reads no longer consume it); the CardTrader export resolver also settles admitted operations older than 60 minutes. A CardTrader Zero batch whose cards were all marked not sent can be cancelled. The eBay hourly run and price-sync drain first mark admitted update operations older than 60 minutes uncertain (already treated as superseded), so an update abandoned by a restart no longer blocks the listing; creations and withdrawals still need review. Requested eBay price syncs approve the existing reviewed Best Offer repair (decline 90%, accept 96.5% of the new price) when rules sit at or above the new price; the hourly sweep still blocks. A retry of an update whose earlier attempt ended uncertain chains a new operation key instead of being refused as a replay. No migration and no new schedule.

Backend diff:

apps/backend/src/admin/components/order/order-attachment-settlement.tsx
apps/backend/src/api/admin/orders/[id]/attachment-zero-cancel/route.ts
apps/backend/src/modules/channel-sync/__tests__/cardnexus-mapping-sync.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/cardtrader-orphaned-admission.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/cardtrader-zero-unsent.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/ebay-abandoned-updates.unit.spec.ts
apps/backend/src/modules/channel-sync/__tests__/ebay-listing-lifecycle.unit.spec.ts
apps/backend/src/modules/channel-sync/adapters/cardnexus-listing-sync.ts
apps/backend/src/modules/channel-sync/adapters/cardtrader-attachment-authority.ts
apps/backend/src/modules/channel-sync/adapters/cardtrader-listing-operation.ts
apps/backend/src/modules/channel-sync/adapters/ebay-listing-lifecycle.ts
apps/backend/src/modules/channel-sync/adapters/ebay-runtime.ts
apps/backend/src/modules/channel-sync/attachment-settlement-sweep.ts
apps/backend/src/modules/channel-sync/ebay-abandoned-updates.ts
apps/backend/src/modules/channel-sync/service.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:37c77e119b864af286c726098b624981af3b91ecb179f38e8125ff2ae5b45e42

Application rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:6bcfa431995330757146cf84fc2a5b5815834ae4ab023b8a322fbb7737c75aae (ed18b4ea741b90380f38c8d5847c677a45bd5bf7); no schema change. No production order, stock or payment mutation is part of release verification.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-22T20:20:59.057Z; live verification pending.
