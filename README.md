# This project is still work in progress


# swag

Secure web application gateway based on nginx with integrated web application firewall, LetsEncrypt, fail2ban and a lot more :wink It is designed as a pure reverse proxy which faces to the public internet. It can also server static files which you lace inside the foler `/config/www`. Of course you can also use this internally but you will not be able to use LetsEncrypt as this requires a http challenge at the moment. The SWAG is designed to secure your application and the data you host on them. It comes with serval well known open source security features like fail2ban ip blocking etc.


# Integrated features

- Letsencrypt support
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
- Volume: /config
- Ports: 80, 443
- Environment variables:
    - TZ=Europe/Berlin            # (optional) Used to define the timezone (e.g. "Europe/Berlin")
    - PUID=                       # (optional) Custom user id if you face any permission issues
    - PGID=                       # (optional) Custom group id if you face any permission issues
    - DOMAIN=example.com          # (required) Main domain for new certificates
    - SUBDOMAINS=www dev.wiki     # (optional) Subdomains for certificates
    - OTHER_DOMAINS=mydomain.com  # (optional) Other domains to include in certificate
    - EMAIL=contact@example.com   # (recommended) Email to use for certificate
    - STAGING="false"             # (required) Use `"true"` for testing, as soon all works switch to `"false"` to avoid rate limits with LetsEncrypt
    - SMTP_SERVER
    - SMTP_SENDER_MAIL
    - SMTP_SENDER_NAME
    - SMTP_RECEIVER
    - SMTP_PASSWORD
    - SMTP_PASSWORD_FILE

### Docker Compose

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
  frontent: # Used as frontend for swag
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
