#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail

# Load env vars from compile image
source /tmp/nginx/envvars.txt

# Install base image components
./tmp/swag-installer/install-base-image.sh

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
    curl-dev \
    fail2ban \
    gnupg \
    inotify-tools \
    libmaxminddb-dev \
    libstdc++ \
    libxml2-dev \
    lmdb-dev \
    memcached \
    nginx~=${NGINX_VERSION} \
    nginx-mod-http-brotli \
    nginx-mod-http-geoip \
    nginx-mod-http-headers-more \
    openssl \
    tzdata \
    yajl


# Prepare fail2ban and move to default as template
echo "**** copy fail2ban config ****"
rm /etc/fail2ban/jail.d/alpine-ssh.conf
mkdir -p /default/fail2ban
mv /etc/fail2ban/action.d /default/fail2ban/
mv /etc/fail2ban/filter.d /default/fail2ban/

# Replace default iptable action to "DROP" instead of "REJECT --reject-with icmp-port-unreachable" as this cause errors on old iptable versions
sed -i 's/^blocktype = .*$/blocktype = DROP/g' /default/fail2ban/action.d/iptables-common.conf

# Copy  ModSecurity nginx module
echo "**** copy ModSecurity binaries ****"
cp /tmp/nginx/ngx_http_modsecurity_module.so /usr/lib/nginx/modules
cp /tmp/nginx/10_http_modsecurity.conf /etc/nginx/modules

# Copy OWASP core rule set for ModSecurity
echo "**** copy OWASP core rule set ****"
mkdir -p /default/nginx/modsec.d
cp /tmp/nginx/owasp-modsecurity-crs/crs-setup.conf.example /default/nginx/modsec.d/crs-setup.conf
cp -r /tmp/nginx/owasp-modsecurity-crs/rules /default/nginx/modsec.d/crs-rules/

# Install ultimate-bad-bot-blocker
chmod +x /tmp/swag-installer/install-ultimate-bad-bot-blocker.sh
./tmp/swag-installer/install-ultimate-bad-bot-blocker.sh


# Apply custom cron config
echo "**** import custom crontabs ****"
mkdir -p /etc/crontabs
crontab -u root /tmp/swag-installer/etc/crontabs/root


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