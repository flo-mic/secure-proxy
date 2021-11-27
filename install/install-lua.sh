#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail

# Move to work dir
cd /tmp

# Add lua-dev as build dependency (only for lua setup, not globally)
apk add --no-cache --virtual=lua-build-dependencies lua-dev

# Clone and install LuaJIT
echo "Install LuaJIT package"
git clone https://github.com/openresty/luajit2 /tmp/openresty_luait
cd /tmp/openresty_luait
git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
make -j${CPU_CORES}
make install
cd /tmp


# Clone and install lua resty core module
echo "Install install lua resty core module"
git clone https://github.com/openresty/lua-resty-core /tmp/lua_resty_core
cd /tmp/lua_resty_core
git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
make -j${CPU_CORES}
make install
cd /tmp


# Clone and install lua resty lrucache module
echo "Install lua resty lrucache module"
git clone https://github.com/openresty/lua-resty-lrucache /tmp/lua_resty_lrucache
cd /tmp/lua_resty_lrucache
git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
make -j${CPU_CORES}
make install
cd /tmp


# Clone and install lua logging module
echo "Install lua logging module"
git clone https://github.com/lunarmodules/lualogging /tmp/lua_logging
cp -r /tmp/lua_logging/src/* /usr/local/lib/lua


# Clone and install lua socket module
echo "Install lua socket module"
git clone https://github.com/diegonehab/luasocket /tmp/lua_socket
cd /tmp/lua_socket
make -j${CPU_CORES}
make CDIR_linux=lib/lua/5.1 LDIR_linux=lib/lua install
cd /tmp


# Clone and install lua sec module
echo "Install lua sec module"
git clone https://github.com/brunoos/luasec.git /tmp/lua_sec
cd /tmp/lua_sec
mkdir -p /usr/local/lib/lua/5.1
make linux -j${CPU_CORES}
make LUACPATH=/usr/local/lib/lua/5.1 LUAPATH=/usr/local/lib/lua install
cd /tmp


# Clone and Install lua cjson module
git clone https://github.com/openresty/lua-cjson /tmp/lua_cjson
cd /tmp/lua_cjson
make -j${CPU_CORES}
make install
cd /tmp
cp -r /tmp/lua_cjson/lua/* /usr/local/lib/lua/


# Clone and Install lua resty string module
git clone https://github.com/openresty/lua-resty-string /tmp/lua_string
cd /tmp/lua_string
make -j${CPU_CORES}
make install
cd /tmp


# Clone and Install lua resty openssl module
git clone https://github.com/fffonion/lua-resty-openssl /tmp/lua_openssl
cp -r /tmp/lua_openssl/lib/resty/* /usr/local/lib/lua/resty/


# Clone and Install lua resty jwt module
git clone https://github.com/cdbattags/lua-resty-jwt /tmp/lua_jwt
cp /tmp/lua_jwt/lib/resty/* /usr/local/lib/lua/resty/


# Clone and Install lua resty hmac module
git clone https://github.com/jkeys089/lua-resty-hmac /tmp/lua_hmac
cp /tmp/lua_hmac/lib/resty/* /usr/local/lib/lua/resty/


# Clone and Install lua resty openidc module
git clone https://github.com/zmartzone/lua-resty-openidc /tmp/lua_openidc
cp /tmp/lua_openidc/lib/resty/* /usr/local/lib/lua/resty/


# Clone and Install lua resty http module
echo "Install lua http module"
RSTRING_VERSION=$(curl https://api.github.com/repos/ledgetech/lua-resty-http/releases/latest -s | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/release-//')
wget --quiet https://github.com/ledgetech/lua-resty-http/archive/refs/tags/${RSTRING_VERSION}.tar.gz
tar -xzf ${RSTRING_VERSION}.tar.gz
RSTRING_VERSION="lua-resty-http-${RSTRING_VERSION:1}"
cp /tmp/${RSTRING_VERSION}/lib/resty/* /usr/local/lib/lua/resty/


# Clone and Install lua resty session module
echo "Install lua httsession module"
RSESSION_VERSION=$(curl https://api.github.com/repos/bungle/lua-resty-session/releases/latest -s | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/release-//')
wget --quiet https://github.com/bungle/lua-resty-session/archive/refs/tags/${RSESSION_VERSION}.tar.gz
tar -xzf ${RSESSION_VERSION}.tar.gz
RSESSION_VERSION="lua-resty-session-${RSESSION_VERSION:1}"
cp -r /tmp/${RSESSION_VERSION}/lib/resty/* /usr/local/lib/lua/resty/


# Remove lua without purging
apk del lua-build-dependencies
