# One-off release: graded-card language as free text with suggestions

On 18 November 2026 the operator requested this change be deployed through the existing one-off process. No hosted Actions workflow, assertion, retry policy or release gate is weakened. The exact committed source is c167d925e79ee534fd6668ac43836faae9885665 (two commits on top of the live a908a11e5ac43a0cc61d5d3fd4ce292784c41b0d: 4d72374b and c167d925; this is the whole of origin/main at pin time), archive SHA-256 52e2d0e16e61b6ad38dda59c0bfc5ffe56661db36d06d3b99a896b3d422c2c4f.

## Full exact-source verification

All six isolated Linux phases passed from 2026-11-18T17:59:03Z to 2026-11-18T18:28:12Z. Backend units: 4892, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Workflow SHA-256 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Evidence: /srv/freesplash-ci/admin/benchmark-20261118T175825Z, local graded-language-release-20261118. Proof inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs..

## Runtime scope

Admin-only change: the Graded card details widget's Language field becomes a required free-text input with a suggestion list (datalist) instead of a fixed dropdown, so values such as Indonesian, Thai or Traditional Chinese can be saved. The graded-details API already validated only a non-empty trimmed value and eBay uses the stored string verbatim; new unit tests cover save, reload and eBay export. No API, schema, order, stock or channel behaviour changes. No order is changed by deployment. Backend diff:

apps/backend/src/admin/widgets/product-graded-details.tsx
apps/backend/src/api/admin/products/[id]/graded-details/__tests__/route.unit.spec.ts

The storefront is unchanged and keeps ghcr.io/craigbanach/tcg-store-storefront@sha256:573f93eb2655b3af96dea01b9012955136d25b716213feff29476bb90c53842a (70434c0152268bb26640ddcc78bbf61bea51f554). Backend packaged proof runs network-disabled/read-only as UID 1000 with the existing pick-safety, health, alert-email and payment-health checks.

Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:ab07f176a174a04a2b55899ddcca33e5abb8e327d899a5480eb7da6aa927df6b

Rollback target: ghcr.io/craigbanach/tcg-store-backend@sha256:674b363d33e0e962f14bafd28882b08f1d0b74d173bb2aabff510e464dab50b2 (a908a11e5ac43a0cc61d5d3fd4ce292784c41b0d). No schema change, order replay, stock adjustment, payment operation or catalog/config script is requested.

## Managed rollout

This task's worker drain acknowledged zero active jobs before GitOps submission. Existing secrets, feature settings and all non-release manifest fields are preserved; config/catalog execution stay false. Require three consecutive uncached exact-digest/source public readiness checks before resuming this task's drain nonce.

Submitted 2026-11-18T18:29:47.503Z; live verification pending.
