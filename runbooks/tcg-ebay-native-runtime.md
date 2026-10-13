# TCG native eBay deployment wiring

The backend supports optional keys in a dedicated environment-scoped Nomad
`.../channel-sync` variable. Its absence does not block template rendering.
It is separate from `.../secrets`, which routine deployment reconciles:

- `channel_sync_mode`: defaults to `disabled`.
- `channel_sync_ebay_runtime_enabled`: defaults to `false`.
- `channel_sync_ebay_runtime_json`: the reviewed private JSON manifest; defaults
  to `{}` while disabled. Never store credentials or buyer payloads here.

The manifest is rendered to `/secrets/ebay-native-runtime.json` inside the backend
container, with `0600` permissions. The backend gets its absolute path through
`CHANNEL_SYNC_EBAY_RUNTIME_FILE`. Changes restart the backend; changing this
template or deploying an application image alone does not enable processing.

Publishing this wiring with the optional keys absent preserves legacy operation.
Do not change `channel_sync_mode` to `active`, enable the worker or activate its
database connection as a preparation step.

Activation is a separately approved coordinated operation: preserve the final
legacy journal/cursor and commitments, drain in-flight legacy writes, establish
the actual UTC fresh-original boundary, install the fully reviewed manifest and
coordinate native connection ownership with worker enablement. Update only the
three approved variable keys, preserving all existing keys with a compare-and-set
against the variable's current index. Never dump the variable into logs or Git.

After the switch verify polling/import/stock publication and plugin picking.
Stopping the native worker does not automatically restore legacy ownership;
retained native effects must never be consumed again by legacy processing.
