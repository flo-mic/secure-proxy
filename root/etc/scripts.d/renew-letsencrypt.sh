#!/usr/bin/with-contenv bash

certbot -n renew \
    --post-hook "cd /config/letsencrypt/live/${DOMAIN} && \
    openssl pkcs12 -export -out privkey.pfx -inkey privkey.pem -in cert.pem -certfile chain.pem -passout pass: && \
    sleep 1 && \
    cat privkey.pem fullchain.pem > priv-fullchain-bundle.pem && \
    sleep 1 && \
    cp -f /config/letsencrypt/live/${DOMAIN}/* /config/letsencrypt/current/ && \
    chown -R swag:swag /config/letsencrypt && \
    nginx -c /config/nginx/nginx.conf -s reload"