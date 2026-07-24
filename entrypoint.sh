#!/bin/sh

set -eu

TOR_DIR=/var/lib/tor
PROSODY_TOR_DIR=/var/lib/tor/prosody
TOR_SERVICE_DIR=$TOR_DIR/prosody
CERT_DIR=/etc/prosody/certs
CERT_HOST_DIR=$CERT_DIR/host
PROSODY_DATA_DIR=/var/lib/prosody
HTTP_FILES_DIR=/etc/prosody/public

chmod 700 "$TOR_DIR" "$PROSODY_TOR_DIR"
chown -R tor:root "$TOR_DIR" "$PROSODY_TOR_DIR"

mkdir -p "$CERT_HOST_DIR"
mkdir -p "$PROSODY_DATA_DIR"

chown -R prosody:prosody "$PROSODY_DATA_DIR"
chmod 755 "$PROSODY_DATA_DIR"

tor -f /etc/tor/torrc &
tor_pid=$!

hostname_file="$TOR_SERVICE_DIR/hostname"

until [ -f "$hostname_file" ] && [ -s "$hostname_file" ]; do
    sleep 1
done

hostname=$(cat "$hostname_file")

echo "============================================"
echo "  YOUR ONION ADDRESS: $hostname"
echo "============================================"

if [ ! -f "$CERT_HOST_DIR/$hostname.crt" ]; then
    awk -v hostname="$hostname" '{gsub(/<HOSTNAME>/, hostname); print}' /entrypoint.d/cert.cnf |
    openssl req -x509 -nodes -newkey rsa:4096 \
        -keyout "$CERT_HOST_DIR/$hostname.key" \
        -out "$CERT_HOST_DIR/$hostname.crt" \
        -config - \
        -extensions req_ext
fi

cp "$CERT_HOST_DIR/$hostname.crt" /etc/prosody/public/

chown -R prosody:prosody "$CERT_HOST_DIR"
chown -R prosody:prosody "$HTTP_FILES_DIR"

awk -v hostname="$hostname" '{gsub(/<HOSTNAME>/, hostname); print}' /etc/prosody/prosody.cfg.lua.orig > /etc/prosody/prosody.cfg.lua

su - prosody -s /bin/sh -c 'proxychains prosody -F' &
prosody_pid=$!

wait "$prosody_pid" "$tor_pid"
