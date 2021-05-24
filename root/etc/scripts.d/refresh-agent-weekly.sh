#!/usr/bin/with-contenv bash

# Make required folders if not already exist
mkdir -p /config/logs/refresh-agent
mkdir -p /tmp/refresh-agent

LOG_FILE=/config/logs/refresh-agent/refresh-agent.log

echo "**** Refreshing GeoIP databases and crowdsec hub configurations... ****" >> tee -a $LOG_FILE


# Refresh current geoip-country-lite database
echo "$(date "+%F %T") Updating GeoIP database" >> $LOG_FILE
curl -sL "https://download.db-ip.com/free/dbip-country-lite-$(date +%Y-%m).mmdb.gz"  \
  -o /tmp/geoip.mmdb.gz 2>&1 | tee -a $LOG_FILE

# Check if GeoIP db for this month was already released, if not download version of previous month
GEOIP_DB_SIZE=$(du -sb "/tmp/geoip.mmdb.gz" | awk '{ print $1 }')
if [[ $GEOIP_DB_SIZE -le 2 ]]; then
    echo "GeoIP DB for \"$(date +%Y-%m)\" not released. Unsing version of previous month."  >> $LOG_FILE
    last_release=$(date -d "$date -1 months" +"%Y-%m")
    curl -sL "https://download.db-ip.com/free/dbip-country-lite-$last_release.mmdb.gz"  \
      -o /tmp/geoip.mmdb.gz 2>&1 | tee -a $LOG_FILE
fi
gunzip -f /tmp/geoip.mmdb.gz
mkdir -p /usr/share/GeoIP
mv -f /tmp/geoip.mmdb /usr/share/GeoIP/geoip.mmdb


# Remove temporary files
rm -r /tmp/refresh-agent
