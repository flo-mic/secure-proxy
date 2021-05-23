#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail

# Move to work dir
cd /tmp

# Clone and install ssdeep package
echo "Install ssdeep package"
SSDEEP_VERSION=$(curl https://api.github.com/repos/ssdeep-project/ssdeep/releases/latest -s | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/release-//')
wget --quiet https://github.com/ssdeep-project/ssdeep/releases/download/release-${SSDEEP_VERSION}/ssdeep-${SSDEEP_VERSION}.tar.gz
tar -xzf ssdeep-${SSDEEP_VERSION}.tar.gz
cd ssdeep-${SSDEEP_VERSION}
./configure 
make -j${CPU_CORES}
make install
cd /tmp


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


# Clone ModSecurity
echo "Install ModSecurity libraries"
git clone -b "v${MODSECURITY_VERSION}" --depth 1 --quiet https://github.com/SpiderLabs/ModSecurity
git -C /tmp/ModSecurity submodule update --init --recursive --quiet


# Install Modsecurity
cd "/tmp/ModSecurity"
./build.sh
./configure --with-lmdb
make -j${CPU_CORES}
make install
cd /tmp


# Get OWASP Core rule set
echo "Get OWASP core rule set"
git clone -b "v${OWASP_VERSION}/master" --depth 1 --quiet https://github.com/coreruleset/coreruleset.git /tmp/owasp-modsecurity-crs
mkdir -p /default/nginx/modsec-owasp-crs.d
mkdir -p /tmp/owasp-modsecurity-crs/plugins # Create missing plugin folder on OWASP 3.3 and prepare already for 3.4
cp /tmp/owasp-modsecurity-crs/crs-setup.conf.example /default/nginx/modsec-owasp-crs.d/crs-setup.conf
cp /tmp/owasp-modsecurity-crs/LICENSE /default/nginx/modsec-owasp-crs.d/LICENSE
cp -r /tmp/owasp-modsecurity-crs/rules /default/nginx/modsec-owasp-crs.d/rules/
cp -r /tmp/owasp-modsecurity-crs/util /default/nginx/modsec-owasp-crs.d/util/
cp -r /tmp/owasp-modsecurity-crs/plugins /default/nginx/modsec-owasp-crs.d/plugins/
