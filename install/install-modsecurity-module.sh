#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail

# Copy env vars for base image
mkdir -p /tmp/nginx
echo "NGINX_VERSION=${NGINX_VERSION}
MODSECURITY_VERSION=${MODSECURITY_VERSION}
OWASP_BRANCH=${OWASP_BRANCH}" > /tmp/nginx/envvars.txt

# Install base components
echo "**** install build packages ****"
apk add --no-cache --virtual=build-dependencies \
    autoconf \
    automake \
    byacc \
	curl-dev \
    flex \
    g++ \
    gcc \
    gd-dev \
    geoip-dev \
    git \
    libc-dev \
    libmaxminddb-dev \
    libstdc++ \
    libtool \
    libxml2-dev \
    libxslt-dev \
	linux-headers \
    lmdb-dev \
    make \
    openssl-dev \
    pcre-dev \
    perl-dev \
	tar \
	wget \
    yajl-dev \
    zlib-dev

# Install reguired packages
apk add --no-cache --upgrade nginx~=${NGINX_VERSION}

# Move to work dir
cd /tmp

# Compile ModSecurity, destination folder is /usr/local/modsecurity
echo "Install ModSecurity libraries"
git clone -b ${MODSECURITY_VERSION} --depth 1 https://github.com/SpiderLabs/ModSecurity
git -C /tmp/ModSecurity submodule update --init --recursive
cd "/tmp/ModSecurity"
./build.sh
./configure --with-lmdb
make
make install
rm -Rf /tmp/ModSecurity \
	/usr/local/modsecurity/lib/libmodsecurity.a \
	/usr/local/modsecurity/lib/libmodsecurity.la
cd /tmp

# Clone ModSecurity nginx connector and download nginx source files
echo 'Clone ModSecurity nginx connector and download nginx source files'
git clone -b master --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git
git clone -b ${OWASP_BRANCH} --depth 1 https://github.com/coreruleset/coreruleset.git /tmp/nginx/owasp-modsecurity-crs
wget -O - https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar -xz

# Get current nginx configuration
NGINX_CONFIGURATION_ARGUMENTS=$(nginx -V 2>&1 | grep 'configure arguments' | sed 's/configure arguments: //' | sed 's/--add-dynamic-module=.*\///')

# Compiling nginx with modules
echo 'Installing Nginx ModSecurity Module'
cd "/tmp/nginx-$NGINX_VERSION"
./configure --add-dynamic-module=../ModSecurity-nginx $NGINX_CONFIGURATION_ARGUMENTS
make modules

# Copy modules and create module configuration
cp /tmp/nginx-$NGINX_VERSION/objs/ngx_http_modsecurity_module.so /tmp/nginx/
echo "load_module \"modules/ngx_http_modsecurity_module.so\";" > /tmp/nginx/10_http_modsecurity.conf
