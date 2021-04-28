# Build image
FROM alpine:latest as compile_modsecurity

ARG NGINX_VERSION=1.18.0
ARG MODSECURITY_VERSION=v3.0.4
ARG OWASP_BRANCH=v3.3/master
ARG SSDEEP_VERSION=2.14.1

#Copy Install scripts
COPY install/ /tmp/swag-installer/

# Install build image components
RUN ./tmp/swag-installer/install-modsecurity-module.sh


# Main image
FROM alpine:latest

LABEL maintainer="flo-mic" \
   description="Secure web application gateway/firewall"

# environment variables
ENV ARCH="x86_64" \    
   MIRROR=http://dl-cdn.alpinelinux.org/alpine \
   PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
   HOME="/root" \
   TERM="xterm"

# add s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64-installer /tmp/

#Copy Install scripts
COPY install/ /tmp/swag-installer/

# Copy artifacts from build image
COPY --from=compile_modsecurity /tmp/nginx /tmp/nginx
COPY --from=compile_modsecurity /usr/local/modsecurity /usr/local/modsecurity
COPY --from=compile_modsecurity /usr/local/lib /usr/local/lib

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

