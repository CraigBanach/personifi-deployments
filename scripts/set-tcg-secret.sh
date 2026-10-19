#!/usr/bin/env bash
# Add or replace ONE key in the TCG Medusa production secrets Nomad variable.
# `nomad var put` replaces the whole variable, so this reads it, changes only the
# named key and writes it back with check-and-set. The value is typed hidden and
# passed on stdin: it never appears in arguments, the environment or output.
# Usage: scripts/set-tcg-secret.sh <lower_snake_case_key>
set -euo pipefail

key="${1:-}"
path="${TCG_SECRETS_VAR:-tcg-store/medusa/production/secrets}"
if [[ ! "$key" =~ ^[a-z][a-z0-9_]{0,63}$ ]]; then
  echo "Usage: $0 <lower_snake_case_key>" >&2
  exit 2
fi

read -rsp "Value for ${key} (input hidden): " value
echo
if [[ -z "$value" ]]; then
  echo "Empty value; nothing changed." >&2
  exit 1
fi

umask 077
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
nomad var get -out json "$path" > "$tmp"

merge='
import json, sys
spec_path, key = sys.argv[1], sys.argv[2]
value = sys.stdin.read()
with open(spec_path) as handle:
    spec = json.load(handle)
items = spec.get("Items") or {}
if not items:
    sys.exit("Refusing to write: the existing variable has no items")
existed = key in items
count = len(items)
items[key] = value
with open(spec_path, "w") as handle:
    json.dump({"Items": items}, handle)
action = "replaced" if existed else "added"
print("%d existing keys kept; %s %s; index %s" % (count, action, key, spec["ModifyIndex"]))
'
summary="$(printf '%s' "$value" | python3 -c "$merge" "$tmp" "$key")"
unset value
index="${summary##* index }"
nomad var put -check-index="$index" -in json "$path" - < "$tmp" > /dev/null
echo "${summary%; index *}"

keys="$(nomad var get -out go-template -template '{{ range $k, $v := .Items }}{{ $k }}{{ "\n" }}{{ end }}' "$path")"
if ! grep -qx "$key" <<< "$keys"; then
  echo "Write did not retain ${key}; review the variable." >&2
  exit 1
fi
echo "Stored. The variable now has $(grep -c . <<< "$keys") keys. The TCG backend restarts to pick it up."
