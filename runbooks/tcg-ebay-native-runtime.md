# TCG native eBay deployment wiring

The backend supports optional keys in a dedicated environment-scoped Nomad
`.../channel-sync` variable. Its absence does not block template rendering.
It is separate from `.../secrets`, which routine deployment reconciles:

- `channel_sync_mode`: defaults to `disabled`.
- `channel_sync_ebay_runtime_enabled`: defaults to `false`.
- `channel_sync_ebay_runtime_json`: the reviewed private JSON manifest; defaults
  to `{}` while disabled. Never store credentials or buyer payloads here.
- `channel_sync_ebay_runtime_parts`: alternatively, an ordered comma-separated
  list of private variable paths, each containing one `json_part` string. Their
  concatenation must be the exact reviewed JSON file. This takes precedence over
  the inline JSON key and supports manifests larger than Nomad's 64 KiB per-variable
  limit. Keep every part below that limit, including its item-key bytes.

The manifest is rendered to `/secrets/ebay-native-runtime.json` inside the backend
container, with `0600` permissions and UID/GID `1000:1000` (the non-root backend
image user). Rendering it root-owned prevents the runtime from reading it even
when HTTP health is green. The backend gets its absolute path through
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

For a multipart manifest, stage all parts under a new immutable bundle path first;
validate their concatenation and file fingerprint before referencing them from the
parent variable. Do not edit individual parts of a live bundle. Updating the parent
is the configuration handoff; a missing part must block rendering rather than
produce a partial configuration. During initial staging the database connection
must remain disabled, so reader enablement alone cannot exclude legacy writers.

After the switch verify polling/import/stock publication and plugin picking.
Before fixing an unreadable live manifest, pause only the runtime enablement
using a compare-and-set that preserves other variable keys. Inspect the stale
polling interval and stock backlog before resumption; never republish ended
offers or re-enable legacy writers. Verify readability as UID 1000 after a
template render/restart, not only with a root diagnostic process.
Stopping the native worker does not automatically restore legacy ownership;
retained native effects must never be consumed again by legacy processing.
