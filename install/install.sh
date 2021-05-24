#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail

# Get available cpu cores to improve compile time
if [[ $RUNS_ON_GITHUB = false ]]; then
    CPU_CORES=$(nproc --all)
else
    CPU_CORES=1
fi
export CPU_CORES

# Install build dependencies
echo "**** install build packages ****"
apk add --no-cache --virtual=build-dependencies \
    autoconf \
    automake \
    byacc \
	cargo \
    flex \
    g++ \
    gcc \
    gd-dev \
    git \
    libc-dev \
    libffi-dev \
    libtool \
    libxslt-dev \
	linux-headers \
	make \
    openssl-dev \
    pcre-dev \
    perl-dev \
    tar \
    wget \
    yajl-dev \
    zlib-dev


# Install runtime packages
echo "**** install runtime packages ****"
apk add --no-cache --upgrade \
    apache2-utils \
    bash \
    ca-certificates \
    certbot \
    clamav \
    clamav-libunrar \
	coreutils \
    curl-dev \
    fail2ban \
    geoip-dev \
    gnupg \
    inotify-tools \
    libmaxminddb-dev \
    libstdc++ \
    libxml2-dev \
    lmdb-dev \
    memcached \
    nano \
    openssl \
    tzdata \
	shadow \
    yajl


# Install base image components
./tmp/secproxy-installer/install-base-image.sh


# Install Lua
./tmp/secproxy-installer/install-lua.sh


# Install Modsecurity
./tmp/secproxy-installer/install-modsecurity.sh


# Install Nginx
./tmp/secproxy-installer/install-nginx.sh


# Install crowdsec
./tmp/secproxy-installer/install-crowdsec.sh


# Install ultimate-bad-bot-blocker
chmod +x /tmp/secproxy-installer/install-ultimate-bad-bot-blocker.sh
./tmp/secproxy-installer/install-ultimate-bad-bot-blocker.sh


# Prepare fail2ban and move to default as template
echo "Prepare fail2ban config"
rm /etc/fail2ban/jail.d/alpine-ssh.conf
mkdir -p /default/fail2ban
mv /etc/fail2ban/action.d /default/fail2ban/
mv /etc/fail2ban/filter.d /default/fail2ban/
# Replace default iptable action to "DROP" instead of "REJECT ..." as this cause errors on old iptable versions
sed -i 's/^blocktype = .*$/blocktype = DROP/g' /default/fail2ban/action.d/iptables-common.conf

# Apply custom cron config
echo "Import custom crontabs"
mkdir -p /etc/crontabs
crontab -u root /tmp/secproxy-installer/etc/crontabs/root


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