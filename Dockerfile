FROM alpine:3.19.1

RUN set -eux; \
    apk add --no-cache tor prosody proxychains-ng openssl

RUN set -eux; \
    mkdir -p /var/lib/tor/prosody; \
    mkdir -p /entrypoint.d

COPY torrc /etc/tor/torrc
COPY entrypoint.sh /entrypoint.sh
COPY cert.cnf /entrypoint.d/cert.cnf
COPY prosody.cfg.lua /etc/prosody/prosody.cfg.lua.orig

RUN chmod +x /entrypoint.sh

STOPSIGNAL SIGQUIT

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
