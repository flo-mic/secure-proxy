#!/usr/bin/with-contenv bash

# Make required folders if not already exist
mkdir -p /config/logs/refresh-agent
mkdir -p /tmp/refresh-agent


# Download current robots list
curl -sL https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/blob/master/robots.txt/robots.txt \
  -o /tmp/refresh-agent/robots.txt
if ! cmp /tmp/refresh-agent/robots.txt /config/www/robots.txt >/dev/null 2>&1
then
  echo "$(date +%F_%T) Updating /config/www/robots.txt as this has changed." >> /config/logs/refresh-agent/agent.log
  mv -f /tmp/refresh-agent/robots.txt /config/www/robots.txt
fi

# download list of active tor adresses
echo "$(date +%F_%T) Updating known tor proxy adresses to /config/nginx/conf.d/tor-proxies.conf." >> /config/logs/refresh-agent/agent.log
curl -sL https://check.torproject.org/exit-addresses | grep ExitAddress | cut -d ' ' -f 2 | sed "s/^/deny /g; s/$/;/g" >> /config/nginx/conf.d/tor-proxies.conf

# Remove temporary files
rm -r /tmp/refresh-agent