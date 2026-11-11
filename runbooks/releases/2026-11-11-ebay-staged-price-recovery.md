# One-off backend release - eBay staged-price recovery

## Approval and exact-source validation

On 11 November 2026 the operator asked "Can you get this live without validation?" so the saved eBay price repairs (ETB 137920073661, Ditto 137920060381, Mewtwo 137920078014) can run; GitHub Actions jobs are not starting (billing/spending-limit annotation). Pinned main source: 6f35aaf91730e43d4e9a245a6b6370bb57ccf988, which is the live backend 32d263e0c6414395b1a2e9c9bd3b6dc3fbf475b2 plus ec255678 (eBay: recover staged price failures and undispatched rule repairs), 3151b57d and 6f35aaf9 (storefront-only address dialog and basket checkout fixes; the storefront image is NOT changed by this release, so those do not ship). No Actions workflow, assertion, retry policy or release gate is changed.

NOT VALIDATED BEFORE PROMOTION: no home-server validation was run for this archive, at the operator's explicit instruction. Evidence at submission: ec255678 carries its own unit and HTTP integration test changes (not executed in this task), and the packaged-image proof below.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:2aa72f3196444b95ae8c1c8643665e6d77f1f3296de8aafc8e46d350fe6d523d
- Validation/build archive SHA-256: 3f3803f426d3fcd3089f67e1a07d3a3e1743fe3bf01a8580a64aef111d38aac5
- Previous backend/application rollback target: 32d263e0c6414395b1a2e9c9bd3b6dc3fbf475b2, ghcr.io/craigbanach/tcg-store-backend@sha256:27b5ee4b7afb3461a3843086c873d83a6246666d71ffabb9ee4e6e9ada49d605
- Retained storefront: 245313fdf88b730f491fa3b97f60835aad28f96f, ghcr.io/craigbanach/tcg-store-storefront@sha256:2f3c50b7f276897c7a7b572ea4402da1ff093f78515209296c5dd2f78da241d2

Changes: ec255678 lets the reconciliation retire an undispatched price request (guard failure before the update_price step) as well as a definitively rejected one, accepts a staged eBay offer price that is still blocked by Best Offer auto-accept/decline thresholds, and plans an explicit price/offer-rule repair (reason explicit_price_offer_rule_repair) for a retained offer even when the live price matches. The packaged image passed network-disabled, read-only execution as UID 1000 (undispatched-retire guard, staged-price Best Offer guard, rule-repair reason, ChatGPT feed route and switch migration still present, admin bundle). No new migrations; the managed migration batch remains enabled with no database rollback or forced replay.

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, then resume only this task's nonce. The previous immutable backend is the application-only rollback target.

Submitted at 2026-11-11T18:20:11.299Z. Verified rollout remains pending; image publication or manifest push alone is not success.
