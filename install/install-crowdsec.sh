#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail

# Move to work dir
cd /tmp

echo "Installing crowdsec bouncers"


# Install lua cs bouncer
git clone https://github.com/crowdsecurity/lua-cs-bouncer /tmp/lua_cs_bouncer
cd /tmp/lua_cs_bouncer
mkdir -p /usr/local/lib/lua/crowdsec
cp lib/*.lua /usr/local/lib/lua/crowdsec
cp template.conf /usr/local/lib/lua/crowdsec/crowdsec.conf

# Correct lua path issues with current lua setup
sed -i 's/require "lrucache"/require "resty.lrucache"/' /usr/local/lib/lua/crowdsec/CrowdSec.lua
sed -i 's/require "config"/require "crowdsec.config"/' /usr/local/lib/lua/crowdsec/CrowdSec.lua
cd /tmp


# Install nginx bouncer
git clone https://github.com/crowdsecurity/cs-nginx-bouncer /tmp/nginx_cs_bouncer
mkdir -p /default/nginx/conf.d
cd /tmp/nginx_cs_bouncer
cp nginx/access.lua /usr/local/lib/lua/crowdsec/access.lua

# Correct lua path and local declaration issues with current lua setup
sed -i 's/ok, err = require "CrowdSec"/local ok, err = require "crowdsec.CrowdSec"/' /usr/local/lib/lua/crowdsec/access.lua

cd /tmp
