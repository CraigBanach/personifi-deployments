#!/bin/bash
set -euo pipefail

DEPLOY_DIR="/opt/personifi-deployments"
SECRETS_FILE="$DEPLOY_DIR/.tcg-store.secrets.env"
APPSETTINGS_FILE="/opt/tcg-store/appsettings.json"

error() {
    echo "ERROR: $1" >&2
    exit 1
}

if [ ! -f "$SECRETS_FILE" ]; then
    error "Missing secrets file: $SECRETS_FILE"
fi

source "$SECRETS_FILE"

: "${TCG_DATABASE_CONNECTION_STRING_DIRECT:?Set TCG_DATABASE_CONNECTION_STRING_DIRECT in $SECRETS_FILE}"

mkdir -p /opt/tcg-store/data-protection-keys /opt/tcg-store/images /opt/tcg-store/files

tmp_file="$(mktemp)"
python3 - "$TCG_DATABASE_CONNECTION_STRING_DIRECT" > "$tmp_file" <<'PY'
import json
import sys

connection_string = sys.argv[1]
config = {
    "ConnectionStrings": {
        "ConnectionString": connection_string,
        "DataProvider": "postgresql",
        "SQLCommandTimeout": None,
        "WithNoLock": False,
    }
}
print(json.dumps(config, indent=2))
PY

cat "$tmp_file" > "$APPSETTINGS_FILE"
rm -f "$tmp_file"
chown -R 108:110 "$APPSETTINGS_FILE" /opt/tcg-store/data-protection-keys /opt/tcg-store/images /opt/tcg-store/files 2>/dev/null || true
chmod 666 "$APPSETTINGS_FILE"
chmod -R 777 /opt/tcg-store/data-protection-keys /opt/tcg-store/images /opt/tcg-store/files

echo "nopCommerce appsettings configured for PostgreSQL."
