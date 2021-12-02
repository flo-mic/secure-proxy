#!/usr/bin/with-contenv bash

# Renew certificates 
./acme.sh --renew-all \
    --ecc \
    --ocsp \
    --home /config/acme.sh/ \
    --cert-home /config/acme.sh/ \
    --config-home /config/acme.sh/ \
    --log /config/logs/acme.sh/acme.log \
    --cert-file /config/acme.sh/current/cert.cer \
    --key-file /config/acme.sh/current/privkey.key \
    --ca-file /config/acme.sh/current/ca.cer \
    --fullchain-file /config/acme.sh/current/fullchain.cer \
    --reloadcmd "nginx -c /config/nginx/nginx.conf -s reload"
