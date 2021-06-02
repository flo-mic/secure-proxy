
# Table of Contents  
- [Secure-Proxy](#Secure-Proxy)  
- [Features](#Features)  
- [Documentation](#Documentation)  
  - [Docker settings](#Docker-Settings)  
  - [Docker-Compose minimal setup](#Docker-Compose-minimal-Setup)
  - [Docker-Compose with Crowdsec](#Docker-Compose-with-Crowdsec)
  - [Nginx configuration](#Nginx-configuration)
  - [GeoIP configuration](#GeoIP-configuration)
- [Other great projects](#Other-great-projects)
 
<br/> 
<a name="Secure-Proxy"/>

# Secure-Proxy

Secure-Proxy based on nginx with integrated web application firewall, Let's Encrypt, fail2ban, Crowdsec, ClamAV upload scan and a lot more 😉. It is designed as a pure reverse proxy which faces to the public internet. It can also server static files which you place inside the folder `/config/www`. It has an integrated Openresty Lua support. You can also use this internally but you will not be able to use Let's Encrypt as this requires a http challenge at the moment. The proxy server is designed to secure your application and the data you host on them. It comes with serval well known open source security features like fail2ban ip blocking, ClamAV, etc.

<br/>
<a name="Features"/>

# Features

- Let's Encrypt support
- Modern web application firewall with ModSecurity and OWASP Core Rule Set
- Crowdsec cloud based protection system
- CalmAV suspicious file scan for all uploaded files
- Anti DDOS enabled
- Block vulnarability scanners
- Prevent SQL and XSS Injection
- Blocks bad-bots, user agents, IP addresses, TOR endpoints and a lot more.
- Automatic update of all blocking, and CRS lists
- Automatic ban by strange behavior
- GeoIP database integration to block/allow specific countries
- Lua Module integrated
- HTTP security headers to prevent click-jacking, sniffing, crawler, etc...
- TLS hardening for modern security
- Nginx leak prevention as non root user
- Improved performance with brotli and server tweaking's
- Mailing agent to be informed about attacks, virus detection and blocking actions
- Automatic file system scan once a week to detect malicious files
- Custom error pages to hide that nginx is running
- Docker dns resolving
- Clean image with auto logrotate

# Features in pipeline
- Cookie challenge with encrypted cookies to prevent bots, something like https://github.com/kyprizel/testcookie-nginx-module or https://medium.com/secjuice/detecting-human-users-is-there-a-way-to-block-enumeration-fuzz-or-web-scan-14102a92f10b
- HTTPv3 support


<br/>
<a name="Documentation"/>

# Documentation

<a name="Docker-Settings"/>

## Docker settings:
All configuration files are stored in `/config`. Therefore it is recommended to make this folder persistent and mount it with an docker volume or local path. The proxy instance is listening on port `80` and `443`. You need to map both ports and also configure port forwarding for both ports. There is no security issue if you open port 80 as there is an immediate redirect to port 443. Port 80 is only required for the initial connect of the Let's Encrypt http challenge.

#### General docker parameters:
- `-p 80:80`
- `-p 443:443`
- `-v /local/path/to/config/folder:/config`
- `--cap-add=NET_ADMIN` (Is required to block suspicious endpoints in case of attacks)

#### Environment variables:

| Name                    | Required    | Description       |
| :---                    |   :----:    | :---              |
| TZ                      | yes         | Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for logs, cron jobs and syncs |
| PUID                    | no          | User id to use in case of permission issues |
| PGID                    | no          | Group id of the user provided in PUID in case of permission issues |
| CERTBOT_DOMAIN          | yes         | Main domain to use, will be the first domain on the Let's Encrypt certificate (e.g. "example.com") |
| CERTBOT_SUBDOMAINS      | no          | Certificate subdomains, provide subdomains seperated by space (e.g. "community" for "community.example.com")    |
| CERTBOT_OTHER_DOMAINS   | no          | Other domains to included in the certificate, seperated by a space (e.g. "mail.example2.com smtp.example2.com")  |
| CERTBOT_EMAIL           | recommended | Email address to use for the certificate. Not needed, but recommended for a proper certificate |
| CERTBOT_STAGING         | yes         | Set to `true` for testing. For production use `false` to get a valid certificate which is trusted by web browsers |
| CLAMAV_SYSTEM_SCAN      | no          | Enables or disables the ClamAV file system scan. Values are `enabled` and `disabled`. Default is `enabled` |
| CLAMAV_ACTION           | no          | Action to perform on infection found. Allowed actions are `delete`, `move` and `ignore`. Default is `delete` |
| CLAMAV_MAIL_REPORT      | no          | Send ClamAV report for file syste scans. Values: 0 = disabled, 1 = if infected, 2 = on every scan. Default is 1  |
| CLAMAV_SCAN_DIR         | no          | Directories to scan, seperated by space. If this is empty the whole filesystem will be scanned |
| CLAMAV_IGNORE_DIR       | no          | Directories to ignore, seperated by space. By default special system locations are ignored but you can add more here |
| CROWDSEC_URL            | no          | URL of the crowdsec instance to use for a cloud based protection system |
| CROWDSEC_API_TOKEN      | no          | API token for crowdsec bouncers, if the `CROWDSEC_API_TOKEN_FILE` is not provided it will use the clear text api token |
| CROWDSEC_API_TOKEN_FILE | no          | API token to use for crowdsec bouncers |
| FAIL2BAN_MAIL_REPORT    | no          | Send a notification mail for ban/unban actions. Values are `enabled` and `disabled`. Default is `enabled` |
| SMTP_SERVER             | no          | Smtp server and port  for email notifications (e.g. "smtp.example.com:587") |
| SMTP_SENDER_MAIL        | no          | Smtp sender address for outgoing mails. Required if you provide the parameter `SMTP_SERVER` |
| SMTP_SENDER_NAME        | no          | Smtp sender name to display on outgoing mails. Required if you provide the parameter `SMTP_SERVER` |
| SMTP_RECEIVER           | no          | Smtp mail receiver for your notifiations. Required if you provide the parameter `SMTP_SERVER` |
| SMTP_PASSWORD           | no          | Smtp account password. Required if parameter `SMTP_SERVER` without `SMTP_PASSWORD_FILE` parameter was used |
| SMTP_PASSWORD_FILE      | no          | Smtp account password which can be linked from a file or an docker secret. It is recommended to use this instead of `SMTP_PASSWORD` as the password is not written in cleartext. Required if parameter `SMTP_SERVER` without `SMTP_PASSWORD` was provided|
| UPDATE_CONFIGURATION    | no          | Configure automatic updates for configuration files. By default the container informs you about config updates in the container log on startup and only updates required configuration files. You need to remove the outdated config files and restart the container to get the latest updates. To configure automatic updates set this variable to `enabled`. This will not delete your configured sites, it will just update the configuration files. Default is `disabled` |

<br/> 
<a name="Docker-Compose-minimal-Setup"/>

## Docker-Compose with minimal settings

This docker-compose file will start the secure-proxy with a minimum of settings and shows how the basic setup is working.
```
version: "3.7"
services:
  secure-proxy:
    image: ghcr.io/flo-mic/secure-proxy:latest
    hostname: secure-proxy
    networks: 
      - backend
    ports:
      - "80:80"
      - "443:443"
    cap_add:
      - NET_ADMIN
    environment:
      - TZ=Europe/Berlin
      - CERTBOT_DOMAIN=example.com   
      - CERTBOT_SUBDOMAINS=www dev.wiki
      - CERTBOT_EMAIL=contact@example.com
      - CERTBOT_STAGING=false
    volumes:
      - data:/config
    restart: unless-stopped
    
networks:
  backend:       # mount your backend applications here to avoid exposing them to the host
    #external:   # Uncommend to use external backend, recommended to allow compose restart without removing the other containers before.
    #  name: application_backend
    
volumes:
  data:
     external: false
```

<br/> 
<a name="Docker-Compose-with-Crowdsec"/>

## Docker-Compose setup with Crowdsec

Crowdsec is an online protection platform which shares bad ip's, attacks and other suspicious with the whole community. If someone faces an attack this attack can be blocked immediately. Also the attack details are shared with the whole community and everyone gets a benefit from this knowledge. Crowdsec is tracking all activities inside the nginx log files and can provide prevention actions like blocking or forcing a captcha request immediately. As this is a cloud based protection system it will share some details from your environment with the whole community. The shared details are a timestamp, ip of the attacker and attack details if an suspicious behavior is detected. 

To get this working with the secure proxy you need to perform the following steps:

1. Create a docker-compose file and place the following content inside the file.
```
version: "3.7"
services:
  secure-proxy:
    image: ghcr.io/flo-mic/secure-proxy:latest
    container_name: secure-proxy
    hostname: secure-proxy
    networks: 
      - backend
      - crowdsec
    ports:
      - "80:80"
      - "443:443"
    cap_add:
      - NET_ADMIN
    environment:
      - TZ=Europe/Berlin
      - CERTBOT_DOMAIN=example.com   
      - CERTBOT_SUBDOMAINS=www dev.wiki
      - CERTBOT_EMAIL=contact@example.com
      - CERTBOT_STAGING=false
      - CROWDSEC_URL=http://crowdsec:8080
      - CROWDSEC_API_TOKEN="" # Will be created later
    volumes:
      - data:/config
      - nginx_logs:/config/logs/nginx
    restart: unless-stopped

  crowdsec:
    image: crowdsecurity/crowdsec
    container_name: crowdsec
    hostname: crowdsec
    networks: 
      - crowdsec
    volumes:
      - crowdsec_config:/etc/crowdsec/
      - crowdsec_data:/var/lib/crowdsec/data/
      - nginx_logs:/var/log/nginx:ro
    environment:
      - COLLECTIONS=crowdsecurity/nginx crowdsecurity/base-http-scenarios crowdsecurity/whitelist-good-actors
      - PARSERS=crowdsecurity/whitelists
      - REGISTER_TO_ONLINE_API=true
    restart: unless-stopped

networks:
  crowdsec:
  backend:       # mount your backend applications here to avoid exposing them to the host
    #external:   # Uncommend to use external backend, recommended to allow compose restart without removing the other containers before.
    #  name: application_backend
    
volumes:
  data:
    external: false
  nginx_logs:
    external: false
  crowdsec_config:
    external: false
  crowdsec_data:
    external: false
```
2. Start Crowdsec from the docker compose file with `docker-compose up -d crowdsec`
3. Update the Crowdsec config to parse nginx log files (If you have another Crowdsec instance with existing config make sure to append the string instead of replacing it)
```
docker-compose exec crowdsec ash -c "echo 'filenames:
  - /var/log/nginx/*access*.log
  - /var/log/nginx/*error*.log
labels:
  type: nginx
---' > /etc/crowdsec/acquis.yaml"
```
4. Connect to the Crowdsec container to generate an api token `docker-compose exec crowdsec cscli bouncers add secure-proxy`
5. Read the api token from the console output and place it inside the environment variable `CROWDSEC_API_TOKEN` in the compose file. (Or save it as docker secret and mount as `CROWDSEC_API_TOKEN_FILE` to avoid writing this as clear text.)
6. Restart the docker-compose to load the api token in the secure-proxy container `docker-compose restart`

<br/> 
<a name="Nginx-configuration"/>

## Nginx configuration

The nginx configuration of the secure-proxy is done with configuration files as you may know from existing nginx setups. There is no integration of environment variables as this would be to complex to realize and the amount of nginx configuration options is just to big. This image comes with a preconfigured nginx which requires modern security settings on all end devices. So old devices which do not use TLS 1.3 are not able to connect. If this is to strict for your use case you can change this settings in the related ssl config file.

### Nginx config locations:

- `/config/nginx/nginx.conf` -> Main configuration file of nginx
- `/config/nginx/bots.d/` -> Directory contains bad and good bots. You can add more bots if needed.
- `/config/nginx/conf.d/` -> Directory contains configurations which are available globaly and loaded in the http directive of nginx.
- `/config/nginx/modsec.d/` -> Directory contains the main configuration files of the ModSecurity web application firewall.
- `/config/nginx/owasp-crs.d/` -> Directory contains the OWASP core rule set for ModSecurity
- `/config/nginx/sites-available/` -> Directory contains all server locations to load. A default location as already available and can be used as reference.
- `/config/nginx/sites-conf.d/` -> Directory contains configurations which will be loaded in the server directive. By default all configurations within this folder are loaded in the available sites.
- `/config/www/` -> Directory contains static websites to serve. By default only an generic index.html site and custom error pages are available. It is recommended to not remove the custom error pages as they are importand to hide the nginx default page which tells an attacker hat this server is running on nginx.


<br/> 
<a name="GeoIP-configuration"/>

## GeoIP configuration

This docker container comes with a Geo-IP database which allows to block specific countries or even better only allow certain countries to block unwanted traffic. If you know from which countries your users are connecting it is recommended to allow only this countries. If you want to open your webserver but still want to block countries which are known for suspicious activities, you can also block specific countries. This is for example useful if you do not want to be attacked by e.g. a chinese or russian hacker group which allways connects from a specific chinese/russian ip (they exist, trust me 😉), you can block all traffic from this countries to avoid such attacks. 

To block such attacks you just need to configure the geoip settings in the related configuration file. The file is located under `/config/nginx/conf.d/geoip.conf`. In this documentation we will show two different settings, one to allow specific countries only and one to block specific countries only. You can adapt the configurations as needed. Just make sure to use the ISO 2 letter country codes inside the file which can be found here: https://www.iban.com/country-codes

### Allow only requests from e.g. Germany, Austria and Switzerland
```
# GeoIP database file, do not modify this part
geoip2 /usr/share/GeoIP/geoip.mmdb {
  	auto_reload 5m;
	$geoip2_metadata_country_build metadata build_epoch;
	$geoip2_data_country_code country iso_code;
}

# GeoIP allow/blocking list
map $geoip2_data_country_code $allowed_country {

    # Default action to choose if does not come from a country listed below. Default is no to block all requests
    default no;
    
    # Allow traffic from Germany, Austria and Switzerland
    AT yes;
    CH yes;
    DE yes;
}
```

### Block requests from e.g. China and Russia
```
# GeoIP database file, do not modify this part
geoip2 /usr/share/GeoIP/geoip.mmdb {
  	auto_reload 5m;
	$geoip2_metadata_country_build metadata build_epoch;
	$geoip2_data_country_code country iso_code;
}

# GeoIP allow/blocking list
map $geoip2_data_country_code $allowed_country {

    # Default action to choose if does not come from a country listed below. Default is yes to allow all requests
    default yes;
    
    # Block traffic from China and Russia
    CN no;
    RU no;
}
```
<br/> 
<a name="Other-great-projects"/>

# Other great projects

- Crowdsec https://crowdsec.net
- Ultimate bad bot blocker https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
- Nikto web server scanner https://github.com/sullo/nikto
- Nginx-errors https://github.com/bartosjiri/nginx-errors
- Let's Encrypt https://letsencrypt.org/de/
- ModSecurity https://github.com/SpiderLabs/ModSecurity
- OWASP Core rule set https://github.com/coreruleset/coreruleset
- ClamAV antivirus https://www.clamav.net
- R-FX Networks LMD AV definitions for Webserver https://www.rfxn.com/projects/linux-malware-detect
- Firehol abusers list https://iplists.firehol.org/?ipset=firehol_abusers_30d
