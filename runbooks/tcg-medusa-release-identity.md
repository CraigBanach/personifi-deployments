# TCG Medusa release identity

`DEPLOY_VERSION` in each task is derived from that task's immutable image digest,
not the deployment script's wall clock. Promoting a new manifest with unchanged
images therefore renders the same job specification. Source/release provenance
remains in `environments/tcg-medusa-production.env` and Git history.

The first adoption changes the old timestamp environment values and can restart
the allocation. Apply through a reviewed GitOps rollout, not as a background
maintenance push. Rendering tests do not call Nomad or read production secrets:

```sh
python3 -m unittest discover -s scripts/tests -p 'test_tcg_release_identity.py'
```

This does **not** promise independent app rollouts: backend, Redis and storefront
still share a Nomad task group. A destructive image update can replace that whole
allocation. Splitting those groups requires a separate, reviewed stateful rollout
plan (particularly Redis's host port and persistent state). Keep database
migration execution unchanged until that plan is validated.
