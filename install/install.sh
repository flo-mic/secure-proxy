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
	tar \
    wget


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
    openssl \
    tzdata


# Prepare fail2ban and move to default as template
echo "**** copy fail2ban config ****"
rm /etc/fail2ban/jail.d/alpine-ssh.conf
mkdir -p /default/fail2ban
mv /etc/fail2ban/action.d /default/fail2ban/
mv /etc/fail2ban/filter.d /default/fail2ban/
# Replace default iptable action to "REJECT" instead of "REJECT --reject-with icmp-port-unreachable" as this cause errors on old iptable versions
sed -i 's/^blocktype = .*$/blocktype = REJECT/g' /default/fail2ban/action.d/iptables-common.conf


# Install ultimate-bad-bot-blocker
chmod +x /tmp/install-ultimate-bad-bot-blocker.sh
./tmp/install-ultimate-bad-bot-blocker.sh


# Apply custom cron config
echo "**** import custom crontabs ****"
mkdir -p /etc/crontabs
crontab -u root /tmp/etc/crontabs/root


# Cleanup before deploying
echo "**** clean build files ****"
apk del --purge \
	build-dependencies
rm -rf \
    /root/.cache \
    /root/.cargo \
    /tmp/* \
    /var/cache/apk/* 
for myfile in *.pyc *.pyo; do \
 	find /usr/lib/python3.*  -iname "${myfile}" -exec rm -f '{}' + \
; done