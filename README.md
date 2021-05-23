# Secure-Proxy

Secure-Proxy based on nginx with integrated web application firewall, Let's Encrypt, fail2ban, ClamAV upload scan and a lot more 😉. It is designed as a pure reverse proxy which faces to the public internet. It can also server static files which you place inside the foler `/config/www`. It has an integrated Openresty Lua support. You can also use this internally but you will not be able to use Let's Encrypt as this requires a http challenge at the moment. The proxy server is designed to secure your application and the data you host on them. It comes with serval well known open source security features like fail2ban ip blocking, ClamAV, etc.


# Integrated features

- Let's Encrypt support
- Modern web application firewall with ModSecurity and OWASP Core Rule Set
- CalmAV Virus, Trojan and Maleware scanner for all uploaded files
- Improved ClamAV signatures to protect web applications like PHP pages
- Automatic file system scan once a week to detect malicious files
- Anti DDOS enabled
- Automatic ban by strange behavior of clients
- GeoIP database integration to block/allow specific countries
- Prevent SQL and XSS Injection
- Blocks bad bots, user agents, spam referrer, adware, robots and known bad IP addresses
- Blocks maleware, ransomeware, click-jacking and click-redirects
- Blocks known TOR adresses
- Mailing agent to be informed about attacks, virus detection and blocking actions
- Automatic update of all blocking, and CRS lists
- HTTP security headers to prevent sniffing, crawler, embedding in other pages and much more
- TLS hardening for modern security
- Nginx leak prevention
- Nginx without privileged root permissions
- Docker dns resolving
- Improved performance with brotli and server tweakings
- Lua Module integrated
- Clean image with auto logrotate
- Custom error pages to hide that nginx is running


# Features in pipeline

- Optional CrowdSec integration
- Single Sign On integration for applications without any authentication

# Documentation

There is no documentation at the moment, it will come soon. If you want to use it have a look at the docker compose file below and the list of available settings. The configuration of your reverse proxies can be configured within the folder `/config/nginx/sites-available`. Other settings are also located in `/config`. 

### Docker settings:
All configuration files are stored in `/config`. Therefore it is recommended to make this folder persistent and mount it with an docker volume or local path. The proxy instance is listening on port `80` and `443`. You need to map both ports and also configure port forwarding for both ports. There is no security issue if you open port 80 as there is an immediate redirect to port 443. Port 80 is only required for the initial connect of the Let's Encrypt http challenge.

#### General docker parameter
- `-p 80:80`
- `-p 443:443`
- `-v /local_path:/config`

#### Environment variables

| Name                  | Required    | Description       |
| :---                  |   :----:    | :---              |
| TZ                    | yes         | Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for logs, cron jobs and syncs |
| PUID                  | no          | User id to use in case of permission issues |
| PGID                  | no          | Group id of the user provided in PUID in case of permission issues |
| CERTBOT_DOMAIN        | yes         | Main domain to use, will be the first domain on the Let's Encrypt certificate (e.g. "example.com") |
| CERTBOT_SUBDOMAINS    | no          | Certificate subdomains, provide subdomains seperated by space (e.g. "community" for "community.example.com")    |
| CERTBOT_OTHER_DOMAINS | no          | Other domains to included in the certificate, seperated by a space (e.g. "mail.example2.com smtp.example2.com")  |
| CERTBOT_EMAIL         | recommended | Email address to use for the certificate. Not needed, but recommended for a proper certificate |
| CERTBOT_STAGING       | yes         | Set to `true` for testing. For production use `false` to get a valid certificate which is trusted by web browsers |
| CLAMAV_SYSTEM_SCAN    | no          | Enables or disables the ClamAV file system scan. Values are `enabled` and `disabled`. Default is `enabled` |
| CLAMAV_ACTION         | no          | Action to perform on infection found. Allowed actions are `delete`, `move` and `ignore`. Default is `delete` |
| CLAMAV_MAIL_REPORT    | no          | Send ClamAV report for file syste scans. Values: 0 = disabled, 1 = if infected, 2 = on every scan. Default is 1  |
| CLAMAV_SCAN_DIR       | no          | Directories to scan, seperated by space. If this is empty the whole filesystem will be scanned |
| CLAMAV_IGNORE_DIR     | no          | Directories to ignore, seperated by space. By default special system locations are ignored but you can add more here |
| FAIL2BAN_MAIL_REPORT  | no          | Send a notification mail for ban/unban actions. Values are `enabled` and `disabled`. Default is `enabled` |
| SMTP_SERVER           | no          | Smtp server and port  for email notifications (e.g. "smtp.example.com:587") |
| SMTP_SENDER_MAIL      | no          | Smtp sender address for outgoing mails. Required if you provide the parameter `SMTP_SERVER` |
| SMTP_SENDER_NAME      | no          | Smtp sender name to display on outgoing mails. Required if you provide the parameter `SMTP_SERVER` |
| SMTP_RECEIVER         | no          | Smtp mail receiver for your notifiations. Required if you provide the parameter `SMTP_SERVER` |
| SMTP_PASSWORD         | no          | Smtp account password. Required if parameter `SMTP_SERVER` without `SMTP_PASSWORD_FILE` parameter was used |
| SMTP_PASSWORD_FILE    | no          | Smtp account password which can be linked from a file or an docker secret. It is recommended to use this instead of `SMTP_PASSWORD` as the password is not written in cleartext. Required if parameter `SMTP_SERVER` without `SMTP_PASSWORD` was provided|


### Docker Compose with minimal settings

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


# Other great projects

- Bunkerized nginx https://github.com/bunkerity/bunkerized-nginx
- Ultimate bad bot blocker https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
- Nikto web server scanner https://github.com/sullo/nikto
- Nginx-errors https://github.com/bartosjiri/nginx-errors
- Let's Encrypt https://letsencrypt.org/de/
- ModSecurity https://github.com/SpiderLabs/ModSecurity
- OWASP Core rule set https://github.com/coreruleset/coreruleset
- ClamAV antivirus https://www.clamav.net
- R-FX Networks LMD AV definitions for Webserver https://www.rfxn.com/projects/linux-malware-detect

