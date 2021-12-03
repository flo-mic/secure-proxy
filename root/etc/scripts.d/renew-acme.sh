#!/usr/bin/with-contenv bash

# Generate renew lock
touch /tmp/acme-renew.lock
sleep 1

# Renew certificates 
chmod +x /etc/cont-init.d/60-acme-config
/etc/cont-init.d/60-acme-config
