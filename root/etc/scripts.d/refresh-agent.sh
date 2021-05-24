#!/usr/bin/with-contenv bash

# Make required folders if not already exist
mkdir -p /config/logs/refresh-agent
mkdir -p /tmp/refresh-agent

LOG_FILE=/config/logs/refresh-agent/refresh-agent.log

echo "**** Refreshing CRS, bad bot, blocking lists, etc... ****" >> tee -a $LOG_FILE


# Download current robots list to webroot as there is no compare needed
echo "$(date "+%F %T") Updating /config/www/robots.txt." >> $LOG_FILE
curl -sL https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/blob/master/robots.txt/robots.txt \
  -o /config/www/robots.txt 2>&1 | tee -a $LOG_FILE


# download list of active tor adresses
curl -sL https://check.torproject.org/exit-addresses | grep ExitAddress | cut -d ' ' -f 2 | sed "s/^/deny /g; s/$/;/g" >> /tmp/refresh-agent/deny-tor-proxies.conf
if ! cmp /tmp/refresh-agent/deny-tor-proxies.conf /config/nginx/conf.d/deny-tor-proxies.conf >/dev/null 2>&1
then
  echo "$(date "+%F %T") Updating known tor proxy adresses to /config/nginx/conf.d/deny-tor-proxies.conf as this has changed." >> $LOG_FILE
  mv -f /tmp/refresh-agent/deny-tor-proxies.conf /config/nginx/conf.d/deny-tor-proxies.conf
fi

# download list of active abuser list from firehole
curl -sL https://iplists.firehol.org/files/firehol_abusers_30d.netset | grep "^[^#]" | sed "s/^/deny /g; s/$/;/g" >> /tmp/refresh-agent/deny-firehole-abuser-30d.conf
if ! cmp /tmp/refresh-agent/deny-firehole-abuser-30d.conf /config/nginx/conf.d/deny-firehole-abuser-30d.conf >/dev/null 2>&1
then
  echo "$(date "+%F %T") Updating known abuser list from firehol to /config/nginx/conf.d/deny-firehole-abuser-30d.conf as this has changed." >> $LOG_FILE
  mv -f /tmp/refresh-agent/deny-firehole-abuser-30d.conf /config/nginx/conf.d/deny-firehole-abuser-30d.conf
fi

# Update ultimate-bad-bot-blocker
# Make installer file executable again in case of automatic update in the meantime
chmod +x /etc/scripts.d/install-ngxblocker
chmod +x /etc/scripts.d/update-ngxblocker

# Update ultimate-bad-bot-blocker
./etc/scripts.d/update-ngxblocker \
    -b /config/nginx/bots.d \
    -c /config/nginx/conf.d \
    -i /etc/scripts.d/install-ngxblocker \
    >> $LOG_FILE 2>&1


# Remove temporary files
rm -r /tmp/refresh-agent
