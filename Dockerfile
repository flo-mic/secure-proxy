
# Main image
FROM alpine:3.13

# Software versions to use
ARG NGINX_VERSION=1.18.0
ARG MODSECURITY_VERSION=3.0.4
ARG OWASP_VERSION=3.3
ARG SSDEEP_VERSION=2.14.1

LABEL maintainer="flo-mic" \
   description="Secure web application gateway"

# environment variables
ENV ARCH="x86_64" \    
   MIRROR=http://dl-cdn.alpinelinux.org/alpine \
   PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
   HOME="/root" \
   TERM="xterm"

#Copy Install scripts
COPY install/ /tmp/swag-installer/

# Install image components
RUN ./tmp/swag-installer/install.sh && rm -rf /tmp/*

# Copy/replace root files
COPY root/ /

# Specify mount volumes
VOLUME /config

# Expose needed ports
EXPOSE 80 443

# Entrypoint of S6 overlay
ENTRYPOINT [ "/init" ]

