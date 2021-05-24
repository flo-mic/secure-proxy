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

# Remove lua without purging
apk del lua-build-dependencies
