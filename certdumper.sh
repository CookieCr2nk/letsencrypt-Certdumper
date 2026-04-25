#!/bin/bash
set -euo pipefail

DOMAIN="example.com"
ARCHIVE_DIR="/etc/letsencrypt/archive/$DOMAIN"
SSL_DIR="/opt/mailserver/mail-data/ssl"
RESTART=false

find_latest() {
    ls -v "$ARCHIVE_DIR/$1"*.pem 2>/dev/null | tail -1 || true
}

update_cert() {
    local src="$1" dst="$2"
    if ! cmp -s "$src" "$dst" 2>/dev/null; then
        cp "$src" "$dst"
        chown mail:mail "$dst"
        chmod 600 "$dst"
        RESTART=true
        echo "UPDATE: $(basename "$dst")"
    else
        echo "OK: $(basename "$dst")"
    fi
}

PRIVKEY=$(find_latest privkey)
CHAIN=$(find_latest chain)
CERT=$(find_latest cert)

[[ -n "$PRIVKEY" ]] || { echo "ERROR: no privkey found for $DOMAIN" >&2; exit 1; }
[[ -n "$CHAIN" ]]   || { echo "ERROR: no chain found for $DOMAIN" >&2; exit 1; }
[[ -n "$CERT" ]]    || { echo "ERROR: no cert found for $DOMAIN" >&2; exit 1; }

update_cert "$PRIVKEY" "$SSL_DIR/server.key"
update_cert "$CHAIN"   "$SSL_DIR/ca.crt"
update_cert "$CERT"    "$SSL_DIR/server.crt"

if $RESTART; then
    docker compose -f /opt/mailserver/docker-compose.yml down
    docker compose -f /opt/mailserver/docker-compose.yml up -d
    echo "RESTART"
fi
