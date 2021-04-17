#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail


# Install base components
echo "**** install build packages ****"
apk add --no-cache --virtual=build-dependencies \
    cargo \
    g++ \
    gcc \
    libffi-dev \
	tar

# Install runtime packages
echo "**** install runtime packages ****"
apk add --no-cache --upgrade \
    apache2-utils \
    ca-certificates \
    certbot \
    certbot-nginx \
    fail2ban \
    gnupg \
    inotify-tools \
    memcached \
    nginx \
    nginx-mod-http-brotli \
    openssl

echo "**** copy fail2ban config ****"
rm /etc/fail2ban/jail.d/alpine-ssh.conf
mkdir -p /default/fail2ban
mv /etc/fail2ban/action.d /default/fail2ban/
mv /etc/fail2ban/filter.d /default/fail2ban/

# Apply custom cron config
echo "**** import custom crontabs ****"
mkdir -p /etc/crontabs
crontab -u root /tmp/etc/crontabs/root

# Cleanup before deploying
echo "**** clean build files ****"
apk del --purge \
	build-dependencies
rm -rf \
    /tmp/* \
    /root/.cache \
    /root/.cargo
for myfile in *.pyc *.pyo; do \
 	find /usr/lib/python3.*  -iname "${myfile}" -exec rm -f '{}' + \
; done