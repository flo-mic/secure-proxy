
# Main image
FROM alpine:latest

# Software versions to use
ARG NGINX_VERSION=1.18.0
ARG MODSECURITY_VERSION=3.0.4
ARG OWASP_VERSION=3.3

# Variable to specify if running on GitHub Action or localy (prevent GitHub action resource issues)
ARG RUNS_ON_GITHUB=false

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

