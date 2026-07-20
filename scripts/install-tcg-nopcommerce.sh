#!/bin/bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://staging.craigscards.co.uk}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@craigscards.co.uk}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:?Set ADMIN_PASSWORD before running this script}"
COUNTRY="${COUNTRY:-United Kingdom}"
INSTALL_SAMPLE_DATA="${INSTALL_SAMPLE_DATA:-false}"
DEPLOY_DIR="${DEPLOY_DIR:-/opt/personifi-deployments}"
SECRETS_FILE="${SECRETS_FILE:-$DEPLOY_DIR/.tcg-store.secrets.env}"

error() {
    echo "ERROR: $1" >&2
    exit 1
}

need() {
    command -v "$1" >/dev/null 2>&1 || error "Missing required command: $1"
}

extract_input_value() {
    python3 - "$1" "$2" <<'PY'
import html
import re
import sys

path, name = sys.argv[1:]
data = open(path, encoding="utf-8", errors="ignore").read()
match = re.search(r'<input[^>]+name="' + re.escape(name) + r'"[^>]*value="([^"]*)"', data, re.I | re.S)
if match:
    print(html.unescape(match.group(1)))
PY
}

extract_select_value() {
    python3 - "$1" "$2" "$3" <<'PY'
import html
import re
import sys

path, select_name, wanted = sys.argv[1:]
data = open(path, encoding="utf-8", errors="ignore").read()
select = re.search(r'<select[^>]+name="' + re.escape(select_name) + r'"[^>]*>(.*?)</select>', data, re.I | re.S)
if not select:
    sys.exit(0)

for option in re.finditer(r'<option[^>]+value="([^"]*)"[^>]*>(.*?)</option>', select.group(1), re.I | re.S):
    text = html.unescape(re.sub(r'<[^>]+>', '', option.group(2)).strip())
    if text == wanted or wanted in text:
        print(html.unescape(option.group(1)))
        sys.exit(0)
PY
}

extract_selected_or_first_value() {
    python3 - "$1" "$2" <<'PY'
import html
import re
import sys

path, select_name = sys.argv[1:]
data = open(path, encoding="utf-8", errors="ignore").read()
select = re.search(r'<select[^>]+name="' + re.escape(select_name) + r'"[^>]*>(.*?)</select>', data, re.I | re.S)
if not select:
    sys.exit(0)

options = list(re.finditer(r'<option[^>]+value="([^"]*)"[^>]*>(.*?)</option>', select.group(1), re.I | re.S))
for option in options:
    if 'selected' in option.group(0).lower():
        print(html.unescape(option.group(1)))
        sys.exit(0)
if options:
    print(html.unescape(options[0].group(1)))
PY
}

parse_connection_string() {
    python3 - "$1" <<'PY'
import sys

parts = {}
for part in sys.argv[1].split(';'):
    if not part or '=' not in part:
        continue
    key, value = part.split('=', 1)
    parts[key.strip().lower()] = value.strip()

for key, env_name in [
    ('host', 'SERVER_NAME'),
    ('database', 'DATABASE_NAME'),
    ('username', 'USERNAME'),
    ('password', 'PASSWORD'),
]:
    value = parts.get(key, '')
    value = value.replace("'", "'\\''")
    print(f"{env_name}='{value}'")
PY
}

need curl
need python3

[ -f "$SECRETS_FILE" ] || error "Missing secrets file: $SECRETS_FILE"
source "$SECRETS_FILE"
: "${TCG_DATABASE_CONNECTION_STRING_DIRECT:?Set TCG_DATABASE_CONNECTION_STRING_DIRECT in $SECRETS_FILE}"

eval "$(parse_connection_string "$TCG_DATABASE_CONNECTION_STRING_DIRECT")"

cookie_file="$(mktemp)"
install_page="$(mktemp)"
response_page="$(mktemp)"
trap 'rm -f "$cookie_file" "$install_page" "$response_page"' EXIT

curl -fsSL -c "$cookie_file" "$BASE_URL/install" -o "$install_page"

token="$(extract_input_value "$install_page" "__RequestVerificationToken")"
country_id="$(extract_select_value "$install_page" "Country" "$COUNTRY")"
if [ -z "$country_id" ]; then
    country_id="$(extract_selected_or_first_value "$install_page" "Country")"
fi
postgres_provider="$(extract_select_value "$install_page" "DataProvider" "PostgreSQL")"

[ -n "$token" ] || error "Could not find installer anti-forgery token. Is nopCommerce already installed?"
[ -n "$country_id" ] || error "Could not determine installer country value."
[ -n "$postgres_provider" ] || error "Could not find PostgreSQL in installer database options."

form_args=(
    --data-urlencode "__RequestVerificationToken=$token"
    --data-urlencode "AdminEmail=$ADMIN_EMAIL"
    --data-urlencode "AdminPassword=$ADMIN_PASSWORD"
    --data-urlencode "ConfirmPassword=$ADMIN_PASSWORD"
    --data-urlencode "Country=$country_id"
    --data-urlencode "DataProvider=$postgres_provider"
    --data-urlencode "ServerName=$SERVER_NAME"
    --data-urlencode "DatabaseName=$DATABASE_NAME"
    --data-urlencode "Username=$USERNAME"
    --data-urlencode "Password=$PASSWORD"
)

if [ "$INSTALL_SAMPLE_DATA" = "true" ]; then
    form_args+=(--data-urlencode "InstallSampleData=true")
fi

curl -fsSL -b "$cookie_file" -c "$cookie_file" -X POST "${form_args[@]}" "$BASE_URL/install" -o "$response_page"

if grep -qi '<title>nopCommerce installation</title>' "$response_page"; then
    python3 - "$response_page" <<'PY' >&2
import html
import re
import sys

data = open(sys.argv[1], encoding="utf-8", errors="ignore").read()
messages = re.findall(r'<span[^>]+class="[^"]*field-validation-error[^"]*"[^>]*>(.*?)</span>|<div[^>]+class="[^"]*validation-summary-errors[^"]*"[^>]*>(.*?)</div>', data, re.I | re.S)
text = []
for pair in messages:
    value = ''.join(pair)
    value = html.unescape(re.sub(r'<[^>]+>', ' ', value)).strip()
    if value:
        text.append(value)
if text:
    print('Install did not complete: ' + '; '.join(text))
else:
    print('Install did not complete; installer page was returned without visible validation errors.')
PY
    exit 1
fi

nomad job restart -yes -on-error fail tcg-store
echo "Install submitted and nopCommerce restarted."
echo "Admin email: $ADMIN_EMAIL"
