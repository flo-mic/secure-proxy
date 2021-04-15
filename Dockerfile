FROM alpine:latest

LABEL \
 maintainer="flo-mic" \
 description="Secure web application gateway/firewall"

##
# BASE image preparation
##

# Install base components
RUN \
 apk add --no-cache \
	bash \
	coreutils \
	curl \
   nano \
	shadow

# environment variables
ENV \
 ARCH="x86_64" \    
 MIRROR=http://dl-cdn.alpinelinux.org/alpine \
 PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
 HOME="/root" \
 TERM="xterm"

# add s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64-installer /tmp/

# Prepare base image
RUN \
 chmod +x /tmp/s6-overlay-amd64-installer && \
 /tmp/s6-overlay-amd64-installer / && \
 rm /tmp/s6-overlay-amd64-installer && \
 # Create user
 echo "**** create user and make folders ****" && \
 groupmod -g 1000 users && \
 useradd -u 911 -U -d /config -s /bin/false swag && \
 usermod -G users swag && \
 mkdir -p \
    /config \
    /default

 ##
 # BASE image preparation done
 ##

 # Install build dependencies
 RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
    cargo \
    g++ \
    gcc \
    libffi-dev \
    #openssl-dev \
    #python3-dev \
    tar && \
 # Install runtime packages
 echo "**** install runtime packages ****" && \
 apk add --no-cache --upgrade \
    apache2-utils \
    ca-certificates \
    fail2ban \
    gnupg \
    memcached \
    nginx && \
 echo "**** copy fail2ban config to /default ****" && \
 rm /etc/fail2ban/jail.d/alpine-ssh.conf && \
 mkdir -p /default/fail2ban && \
 mv /etc/fail2ban/action.d /default/fail2ban/ && \
 mv /etc/fail2ban/filter.d /default/fail2ban/ && \
 # Cleanup before deploying
 echo "**** clean build files ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
    /tmp/* \
    /root/.cache \
    /root/.cargo && \
for myfile in *.pyc *.pyo; do \
 	find /usr/lib/python3.*  -iname "${myfile}" -exec rm -f '{}' + \
 	; done

# Copy/replace root files
COPY root/ /

# Init
ENTRYPOINT [ "/init" ]

