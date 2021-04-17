FROM alpine:latest

##
# BASE image preparation
##

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
COPY install/ /tmp/

# Install base image
RUN ./tmp/install-baseimage.sh

##
# BASE image preparation done
##

# Install image components
RUN ./tmp/install.sh && rm -rf /tmp/*

# Copy/replace root files
COPY root/ /

# Specify mount volumes
VOLUME /config

# Expose needed ports
EXPOSE 80 443

# Entrypoint of S6 overlay
ENTRYPOINT [ "/init" ]

