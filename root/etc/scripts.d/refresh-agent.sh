#!/usr/bin/with-contenv bash

# Function to validate a updated config file before loading into production
validate_config(){

  # Copy configuration file to temporary nginx
  cp ${1} /etc/nginx/conf.d/

  # test conf file against nginx config
  if /usr/sbin/nginx -c /etc/nginx/nginx.conf -t 2> $LOG_FILE; then
    rm /etc/nginx/conf.d/*
    return 0;
  else
    echo "$(date "+%F %T") Validation of configuration file ${1} failed, skipping this file for reload." | tee -a $LOG_FILE
    rm /etc/nginx/conf.d/*
    return 1;
  fi  
}


# Make required folders if not already exist
mkdir -p /config/logs/refresh-agent
mkdir -p /tmp/refresh-agent

LOG_FILE=/config/logs/refresh-agent/refresh-agent.log


# Download current robots list to webroot as there is no compare needed
FILE=/config/www/robots.txt
if [[ ! -f "$FILE" || $(find "${FILE}" -mtime +1 -print) ]]; then
  echo "$(date "+%F %T") Updating ${FILE}." >> $LOG_FILE
  curl -sL https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/blob/master/robots.txt/robots.txt \
    -o $FILE 2>&1 | tee -a $LOG_FILE
fi


# download list of active tor adresses
FILE=/config/nginx/conf.d/deny-tor-proxies.conf
if [[ ! -f "$FILE" || $(find "${FILE}" -mtime +1 -print) ]]; then
  cp /default/nginx/conf.d/deny-tor-proxies.conf /tmp/refresh-agent/deny-tor-proxies.conf
  curl -sL https://check.torproject.org/exit-addresses | grep ExitAddress | cut -d ' ' -f 2 | sed "s/^/deny /g; s/$/;/g" >> /tmp/refresh-agent/deny-tor-proxies.conf
  if ! cmp /tmp/refresh-agent/deny-tor-proxies.conf $FILE >/dev/null 2>&1
  then
    if validate_config /tmp/refresh-agent/deny-tor-proxies.conf; then 
      echo "$(date "+%F %T") Updating known tor proxy adresses to ${FILE} as this has changed." >> $LOG_FILE
      mv -f /tmp/refresh-agent/deny-tor-proxies.conf $FILE
    fi
  fi
fi


# download list of bad ip addresses
FILE=/config/nginx/conf.d/deny-bad-ip-addresses.conf
if [[ ! -f "$FILE" || $(find "${FILE}" -mtime +1 -print) ]]; then
  cp /default/nginx/conf.d/deny-bad-ip-addresses.conf /tmp/refresh-agent/deny-bad-ip-addresses.conf
  curl -sL https://iplists.firehol.org/files/firehol_abusers_30d.netset | grep "^[^#]" | sed "s/^/deny /g; s/$/;/g" >> /tmp/refresh-agent/deny-bad-ip-addresses.conf
  if ! cmp /tmp/refresh-agent/deny-bad-ip-addresses.conf $FILE >/dev/null 2>&1
  then
    if validate_config /tmp/refresh-agent/deny-bad-ip-addresses.conf; then 
      echo "$(date "+%F %T") Updating known bad ip address list from firehol to ${FILE} as this has changed." >> $LOG_FILE
      mv -f /tmp/refresh-agent/deny-bad-ip-addresses.conf $FILE
    fi
  fi
fi


# download list of bad ip addresses
FILE=/config/nginx/conf.d/deny-bad-ip-addresses.conf
if [[ ! -f "$FILE" || $(find "${FILE}" -mtime +1 -print) ]]; then
  cp /default/nginx/conf.d/deny-bad-ip-addresses.conf /tmp/refresh-agent/deny-bad-ip-addresses.conf
  curl -sL https://iplists.firehol.org/files/firehol_abusers_30d.netset | grep "^[^#]" | sed "s/^/deny /g; s/$/;/g" >> /tmp/refresh-agent/deny-bad-ip-addresses.conf
  if ! cmp /tmp/refresh-agent/deny-bad-ip-addresses.conf $FILE >/dev/null 2>&1
  then
    if validate_config /tmp/refresh-agent/deny-bad-ip-addresses.conf; then 
      echo "$(date "+%F %T") Updating known bad ip address list from firehol to ${FILE} as this has changed." >> $LOG_FILE
      mv -f /tmp/refresh-agent/deny-bad-ip-addresses.conf $FILE
    fi
  fi
fi


# download lists of bad user agents from ultimate bad bot blocker
FILE=/config/nginx/conf.d/deny-bad-user-agents.conf
if [[ ! -f "$FILE" || $(find "${FILE}" -mtime +1 -print) ]]; then
  cp /default/nginx/conf.d/deny-bad-user-agents.conf /tmp/refresh-agent/deny-bad-user-agents.conf
  sed -i '$ d' /tmp/refresh-agent/deny-bad-user-agents.conf
  curl -sL https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/bad-user-agents.list | sed 's/^/\t"~*(?:\\b)/g; s/$/(?:\\b)"\t1;/g' >> /tmp/refresh-agent/deny-bad-user-agents.conf
  echo "}" >> /tmp/refresh-agent/deny-bad-user-agents.conf
  if ! cmp /tmp/refresh-agent/deny-bad-user-agents.conf $FILE >/dev/null 2>&1
  then
    if validate_config /tmp/refresh-agent/deny-bad-user-agents.conf; then 
      echo "$(date "+%F %T") Updating known bad user agent list to ${FILE} as this has changed." >> $LOG_FILE
      mv -f /tmp/refresh-agent/deny-bad-user-agents.conf $FILE
    fi
  fi
fi


# download lists of bad referers from ultimate bad bot blocker
FILE=/config/nginx/conf.d/deny-bad-referers.conf
if [[ ! -f "$FILE" || $(find "${FILE}" -mtime +1 -print) ]]; then
  cp /default/nginx/conf.d/deny-bad-referers.conf /tmp/refresh-agent/deny-bad-referers.conf
  sed -i '$ d' /tmp/refresh-agent/deny-bad-referers.conf
  curl -sL https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list | sed 's/\-/\\-/g; s/\./\\./g; s/^/\t"~*(?:\\b)/g; s/$/(?:\\b)"\t1;/g' >> /tmp/refresh-agent/deny-bad-referers.conf
  echo "}" >> /tmp/refresh-agent/deny-bad-referers.conf
  if ! cmp /tmp/refresh-agent/deny-bad-referers.conf $FILE >/dev/null 2>&1
  then
    if validate_config /tmp/refresh-agent/deny-bad-referers.conf; then 
      echo "$(date "+%F %T") Updating known bad user agent list to ${FILE} as this has changed." >> $LOG_FILE
      mv -f /tmp/refresh-agent/deny-bad-referers.conf $FILE
    fi
  fi
fi