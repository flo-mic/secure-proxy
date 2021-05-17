#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail


# Download S6 Overlay files
if [[ ${ARCH} = "x86_64" ]]; then
    wget --quiet https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64-installer -O /tmp/s6-overlay-installer
else
    wget --quiet https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-arm-installer -O /tmp/s6-overlay-installer
fi

# Install S6 overlay
echo "**** Install S6 overlay ****"
chmod +x /tmp/s6-overlay-installer
/tmp/s6-overlay-installer /
rm /tmp/s6-overlay-installer


# Create user
echo "**** create user and make folders ****"
groupmod -g 1000 users
useradd -u 911 -U -d /config -s /bin/false swag
usermod -G users swag
mkdir -p \
    /config \
    /default