# This project is still work in progress


# swag

Secure web application gateway based on nginx with integrated web application firewall, Let's Encrypt, fail2ban and a lot more 😉 It is designed as a pure reverse proxy which faces to the public internet. It can also server static files which you lace inside the foler `/config/www`. Of course you can also use this internally but you will not be able to use LetsEncrypt as this requires a http challenge at the moment. The SWAG is designed to secure your application and the data you host on them. It comes with serval well known open source security features like fail2ban ip blocking etc.


# Integrated features

- Let's Encrypt support
- Docker dns resolving
- Nginx runs without privileged root permissions
- Anti DDOS enabled with nginx rate limits
- Prevents bruteforce attacks
- Blocks bad bots, user agents, spam referrer, adware, robots and known bad ips addresses
- Blocks maleware, ransomeware, click-jacking and click-redirects
- Blocks known TOR adresses
- Mailing agent to be informed about attacks and blocking actions
- Automatic update of all blocking, and CRS lists
- HTTP security headers to prevent sniffing, crawler, embedding in other pages and much more
- TLS hardening for modern security
- Nginx leak prevention
- Improved pervormance with brotli and server tweakings
- Clean image with auto logrotate
- Custom error page, also for bots to hide that we are running on a nginx

I need to mention that a lot of the listed security features are part of the "[Ultimate Bad Bot Blocker](https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker)" from [mitchellkrogza](https://github.com/mitchellkrogza). So many thanks to this great project which is great project and really well maintained!

# Features in pipeline

- Modern web application firewall with ModSecurity and OWASP Core Rule Set
- GeoIP blocking
- CalmAV Virus, Trojan and maleware scanner -> Depens on ModSecurity
- Authelia 2-factor single sign on integration

# Documentation

There is no documentation at the moment, it will come soon. If you want to use it have a look at the docker compose file below and the list of available settings. The configuration of your reverse proxies can be configured within the folder `/config/nginx`. Other settings are also located in `/config`. 

### Docker settings:
All configuration files are stored in `/config`. Therefore it is recommended to make this folder persistent and mount it with an docker volume or local path. The SWAG instance is listening on port `80` and `443`. You need to map both ports and also configure portforwarding for poth ports. There is no security issue if you open port 80 as well as there is an immerdiate redirect to port 443. Port 80 is only required for the Let's Encrypt http challenge.

#### General docker parameter
- `-p 80:80`
- `-p 443:443`
- `-v /local_path:/config`

#### Environment variables

| Name               | Required      | Description       |
| :---               |    :----:     | :---              |
| TZ                 | yes           | Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for logs, cron jobs and syncs |
| PUID               | no            | User id to use in case of permission issues |
| PGID               | no            | Group id of the user provided in PUID in case of permission issues |
| DOMAIN             | yes           | Main domain to use, will be the first domain on the Let's Encrypt certificate (e.g. "example.com") |
| SUBDOMAINS         | no            | Subdomains for this certificate, only provide the subdomains seperated by space (e.g. "community" if you want "community.example.com") |
| OTHER_DOMAINS      | no            | Other domains that should be included in the certificate, seperate them by a space (e.g. "mail.example2.com smtp.example2.com")  |
| EMAIL              | recommended   | Email address to use for the certificate. Not needed, but recommended for a proper certificate |
| STAGING            | yes           | Set to `true` for testing for higher rate limits. For production use `false` to get a valid certificate which is trusted by web browsers |
| SMTP_SERVER        | no            | Smtp server and port  for email notifications (e.g. "smtp.example.com:587" |
| SMTP_SENDER_MAIL   | no            | Smtp sender address for outgoing mails. Required if you provide the parameter `SMTP_SERVER` |
| SMTP_SENDER_NAME   | no            | Smtp sender name to display on outgoing mails. Required if you provide the parameter `SMTP_SERVER` |
| SMTP_RECEIVER      | no            | Smtp mail receiver for your notifiations. Required if you provide the parameter `SMTP_SERVER` |
| SMTP_PASSWORD      | no            | Smtp account password for outgoing mails. Required if you provide the parameter `SMTP_SERVER` and don't provide the `SMTP_PASSWORD_FILE`parameter |
| SMTP_PASSWORD_FILE | no            | Smtp account password which can be linked from a file or an docker secret. It is recommended to use this instead of `SMTP_PASSWORD` as the password is not written in cleartext inside the docker file. Required if you provide the parameter `SMTP_SERVER` and dont provide `SMTP_PASSWORD` |


### Docker Compose with minimal settings

```
version: "3.7"
services:
  swag:
    image: ghcr.io/flo-mic/swag:latest
    hostname: swag
    networks: 
       - frontend
       - backend
    dns:
       - 8.8.8.8
    ports:
      - "80:80"
      - "443:443"
    cap_add:
      - NET_ADMIN
    environment:
      - TZ=Europe/Berlin
      - DOMAIN=example.com   
      - SUBDOMAINS=www dev.wiki
      - EMAIL=contact@example.com
      - STAGING=false
    volumes:
      - data:/config
    restart: unless-stopped
    
networks:
  frontent:      # Used as frontend for swag
  backend:       # mount your backend applications here to avoid exposing them to the host
    #external:   # Uncommend to use external backend, recommended to allow compose restart without removing the other containers before.
    #  name: swag_backend
    
volumes:
  data:
     external: false
```


# Other great projects

- Bunkerized nginx https://github.com/bunkerity/bunkerized-nginx
- Ultimate bad bot blocker https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
- Linuxserver SWAG https://github.com/linuxserver/docker-swag
- Nikto web server scanner https://github.com/sullo/nikto
- Nginx-errors https://github.com/bartosjiri/nginx-errors
- Let's Encrypt https://letsencrypt.org/de/
