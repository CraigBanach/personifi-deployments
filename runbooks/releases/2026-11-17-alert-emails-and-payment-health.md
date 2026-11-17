# One-off release: alert email recipients and payment health alerts

On 17 November 2026 the operator requested deployment through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is e92e9c3fc20f6a6c23b061f17f1b93b4851da95b (two commits on top of the live d1303e34bd55051bf044e84bc661aeb9ebc335ee), archive SHA-256 60f96b2e074c8b65348910aa25a0e4465d6dc053a03e2c021f9df18a47c2ac18.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-17T11:44:43Z to 2026-11-17T12:13:06Z. Backend units: 4704, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261117T114403Z, local alert-email-release-20261117-r2. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

Adds an "Alert emails" section to Channels -> Overview for CARDMARKET_ALERT_TO_EMAIL and PAYMENT_ALERT_TO_EMAIL (one validated mailbox each), stored in the new channel_alert_email table (additive migration Migration20261117120000) and laid over the deployment value like channel keys and switches. The Cardmarket health job refreshes the overlay before running. Server-level fallbacks were stored by the operator's request in the secrets variable (cardmarket_alert_to_email, payment_alert_to_email) and are mapped by template commit b8f5970. Backend diff:

apps/backend/.env.template
apps/backend/src/admin/components/alert-emails.tsx
apps/backend/src/admin/routes/channels/page.tsx
apps/backend/src/api/admin/channel-sync/alert-emails/[name]/route.ts
apps/backend/src/api/admin/channel-sync/alert-emails/route.ts
apps/backend/src/config/preload-channel-settings.ts
apps/backend/src/jobs/cardmarket-health.ts
apps/backend/src/jobs/payment-health.ts
apps/backend/src/lib/__tests__/payment-health.unit.spec.ts
apps/backend/src/lib/payment-health.ts
apps/backend/src/modules/channel-sync/__tests__/channel-credentials.unit.spec.ts
apps/backend/src/modules/channel-sync/channel-credentials.ts
apps/backend/src/modules/channel-sync/migrations/Migration20261117120000.ts
apps/backend/src/scripts/payment-health-check.ts
apps/backend/src/subscribers/__tests__/transactional-email.unit.spec.ts
apps/backend/src/subscribers/send-order-confirmation.ts

Also adds a five-minute read-only payment health watchdog: recent Stripe PaymentIntents for Medusa sessions are compared with orders/payments, alerting on captured or authorised payments without an order after ten minutes, overdue or unreconciled captures, non-card processing errors and Stripe orders missing a successful confirmation email after fifteen minutes; capture failures in the order-confirmation subscriber also alert. Alert-only (no capture, refund, cart completion or stock change), no customer data in mail, deduplicated per issue/recipient/UTC day, disabled while PAYMENT_ALERT_TO_EMAIL is empty. Stripe reads use the existing STRIPE_API_KEY.

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:5b3d28f31ae9b4d2ed82bc2b40c226648bf0283abb9ba6ed74325d436c26d4f7 (d1303e34bd55051bf044e84bc661aeb9ebc335ee). Backend packaged proof runs network-disabled/read-only as UID 1000 and exercises the alert-email overlay, migration, admin bundle and route plus the existing pick-safety and health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:1ad021be4e1923354e5aeabd6d09a11dbc226ab227894cc7aaaa2b715b7a5c14

Rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:b40d852e8276e48ce25cf22cbec30a422ecfd4b472cee51d449a43c1d49362a8 (d1303e34bd55051bf044e84bc661aeb9ebc335ee); the new table is additive and may remain. No order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-17T12:15:50.305Z; live verification pending.
