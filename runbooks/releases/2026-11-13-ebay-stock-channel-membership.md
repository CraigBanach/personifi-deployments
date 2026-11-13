# One-off backend release - eBay stock for eBay-channel-only products

## Approval and exact-source validation

On 13 November 2026 the operator asked for this commit to be promoted using the one-off promotion process ("Promote the commit, but use the one-off promotion process we've been using recently") while GitHub Actions jobs are not starting (billing/spending-limit annotation). Pinned main source: e23b4e2311958a50a26205cbfdb4f6c20126578b, which is the live backend 8882e4a980715a465032a01db86c45b4ab650e51 plus two storefront-only commits already live in the storefront (15cdb660, 69ff1a30) and two backend commits (1f63cb62, e23b4e23; the second moves the eBay rule into marketplace composition after the first failed the provider-neutral contract test in exact-source validation). No Actions workflow, assertion, retry policy or release gate is changed.

Full isolated Linux validation passed from 2026-11-13T11:36:36Z to 2026-11-13T12:05:40Z, all six phases successful. Backend units: 4558 passed, zero failed. Browser checks: 105 read-only and 38 stateful, zero unexpected/flaky outcomes. Retained evidence: /srv/freesplash-ci/admin/benchmark-20261113T113557Z. Frozen workflow SHA-256: 7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a. Stock-safety inventory: Multichannel proof: 633 passed exactly once (460 standard, 173 recovery); 2 TODOs.

## Immutable images and scope

- Backend: ghcr.io/craigbanach/tcg-store-backend@sha256:99bd778bf6090b6e9940ae983c82e4797a248537468192ac679806ac8ffa19ab
- Validation/build archive SHA-256: e7c501b3ce0975b905a41132331e99fa47f945a7512ba87eeef2307100ac79fa
- Previous backend/application rollback target: 8882e4a980715a465032a01db86c45b4ab650e51, ghcr.io/craigbanach/tcg-store-backend@sha256:0af2af8ef81409e345efe2ff03522239e4b848bd6fad452b2723f585c0db78e5
- Retained storefront: 69ff1a30fe166e5aabdd824d8728a234bd1983b6, ghcr.io/craigbanach/tcg-store-storefront@sha256:26025559da79361d57f7b203d0359fedea6094ec7a20b9308386a9ce25fc772d

Change: eBay availability now accepts membership of either the website stock channel or the eBay listing channel (creation planner, listing evidence, outbound stock sync and the final pre-publication availability check). Stock still only comes from locations linked to the website stock channel, so dispatch-location reservation rules are unchanged and no product already in the website channel can gain or lose stock. CardTrader, CardNexus and Cardmarket still gate on their own channel. No migration. Application rollback to 8882e4a9 is safe (eBay-only products simply return to zero availability). The packaged image passed network-disabled, read-only execution as UID 1000 (website-member availability unchanged, eBay-only counts linked locations only, other/disabled/draft stay zero, all four call sites wired).

## Managed rollout and limits

The task-owned Cardmarket maintenance drain acknowledged zero active jobs before submission. Credentials, feature gates, configuration/catalog flags, production-data mutation setting and storefront digest are preserved. Retain this task's drain nonce until three consecutive checks prove exact backend source/digest, unchanged storefront source/digest, API health and /gb, then resume only this task's nonce. The previous immutable backend is the application-only rollback target.

Submitted at 2026-11-13T12:06:14.561Z. Verified rollout remains pending; image publication or manifest push alone is not success.
