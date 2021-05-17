#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail

# Move to work dir
cd /tmp


# Clone nginx
echo "Get nginx source files"
wget --quiet https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -O /tmp/nginx-$NGINX_VERSION.tar.gz
tar -xzf nginx-$NGINX_VERSION.tar.gz


# Clone nginx brotli module
echo "Get nginx brotli module"
git clone https://github.com/google/ngx_brotli /tmp/nginx_brotli_module
cd /tmp/nginx_brotli_module
git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
cd /tmp


# Clone nginx http-headers-more module
echo "Get nginx http-headers-more module"
git clone https://github.com/openresty/headers-more-nginx-module /tmp/nginx_http_headers_more_module
cd /tmp/nginx_http_headers_more_module
git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
cd /tmp


# Clone nginx dev tools
echo "Get nginx dev tools"
git clone https://github.com/vision5/ngx_devel_kit /tmp/nginx_devel_kit
cd /tmp/nginx_devel_kit
git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
cd /tmp


# Clone nginx geoip module
echo "Get nginx geoip module"
git clone https://github.com/leev/ngx_http_geoip2_module /tmp/nginx_geoip2_module


# Clone Lua nginx module
echo "Get nginx lua module"
git clone https://github.com/openresty/lua-nginx-module /tmp/nginx_lua_module
cd /tmp/nginx_lua_module
git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
cd /tmp


# Clone Lua stream nginx module
echo "Get nginx lua stream module"
git clone https://github.com/openresty/stream-lua-nginx-module /tmp/nginx_lua_stream_module
cd /tmp/nginx_lua_stream_module
git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
cd /tmp


# Clone ModSecurity nginx connector
echo "Get ModSecurity nginx connector"
git clone -b master --depth 1 --quiet https://github.com/SpiderLabs/ModSecurity-nginx.git /tmp/nginx_modsecurity_module


# tell nginx's build system where to find LuaJIT:
OPENRESTY_PATH=$(find /usr/local/include/ -maxdepth 1 -type d -name 'luajit-*' -print -quit)
export LUAJIT_LIB=/usr/local/lib/
export LUAJIT_INC=${OPENRESTY_PATH}/


# Compiling nginx with modules
echo 'Compile Nginx'
cd "/tmp/nginx-$NGINX_VERSION"
./configure \
    --user=secproxy \
    --group=secproxy \
    --prefix=/var/lib/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/nginx.lock \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_geoip_module \
    --with-http_sub_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-ld-opt="-Wl,-rpath,${OPENRESTY_PATH}" \
    --with-mail=dynamic \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module \
    --with-stream_ssl_preread_module \
    --add-module=../nginx_brotli_module \
    --add-module=../nginx_devel_kit \
    --add-module=../nginx_geoip2_module \
    --add-module=../nginx_http_headers_more_module \
    --add-module=../nginx_lua_module \
    --add-module=../nginx_lua_stream_module \
    --add-module=../nginx_modsecurity_module
make -j${CPU_CORES}
make install

cd /