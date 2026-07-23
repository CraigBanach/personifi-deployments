#!/bin/bash
set -euo pipefail

PLUGIN_ZIP="${1:-}"
PLUGIN_ROOT="/opt/tcg-store/plugins"
RUN_AS_UID="108"
RUN_AS_GID="110"

if [ -z "$PLUGIN_ZIP" ]; then
    echo "Usage: $0 /path/to/plugin.zip" >&2
    exit 1
fi

if [ ! -f "$PLUGIN_ZIP" ]; then
    echo "Plugin zip not found: $PLUGIN_ZIP" >&2
    exit 1
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

unzip -q "$PLUGIN_ZIP" -d "$TMP_DIR"

SOURCE_DIR="$TMP_DIR"
if [ -d "$TMP_DIR/Build" ]; then
    SOURCE_DIR="$TMP_DIR/Build"
fi

mkdir -p "$PLUGIN_ROOT"
chown -R "$RUN_AS_UID:$RUN_AS_GID" "$PLUGIN_ROOT" 2>/dev/null || true
chmod -R 777 "$PLUGIN_ROOT" 2>/dev/null || true

for PLUGIN_DIR in "$SOURCE_DIR"/*; do
    if [ -d "$PLUGIN_DIR" ] && [ -f "$PLUGIN_DIR/plugin.json" ]; then
        DEST_DIR="$PLUGIN_ROOT/$(basename "$PLUGIN_DIR")"
        rm -rf "$DEST_DIR"
        mkdir -p "$DEST_DIR"
        cp -a "$PLUGIN_DIR"/. "$DEST_DIR"/
    fi
done

chown -R "$RUN_AS_UID:$RUN_AS_GID" "$PLUGIN_ROOT" 2>/dev/null || true
chmod -R 777 "$PLUGIN_ROOT" 2>/dev/null || true

echo "Installed plugin files to $PLUGIN_ROOT"
