#!/usr/bin/with-contenv bash

certbot -n renew \
    --post-hook "cd /config/letsencrypt/live/${CERTBOT_DOMAIN} && \
    openssl pkcs12 -export -out privkey.pfx -inkey privkey.pem -in cert.pem -certfile chain.pem -passout pass: && \
    sleep 1 && \
    cat privkey.pem fullchain.pem > priv-fullchain-bundle.pem && \
    sleep 1 && \
    cp -f /config/letsencrypt/live/${CERTBOT_DOMAIN}/* /config/letsencrypt/current/ && \
    chown -R secproxy:secproxy /config/letsencrypt && \
    nginx -c /config/nginx/nginx.conf -s reload"