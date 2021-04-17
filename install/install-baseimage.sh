#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail


# Install base components
echo "**** Install base components ****"
apk add --no-cache \
	bash \
	coreutils \
	curl \
    nano \
	shadow

# Install S6 overlay
echo "**** Install S6 overlay ****"
chmod +x /tmp/s6-overlay-amd64-installer
/tmp/s6-overlay-amd64-installer /
rm /tmp/s6-overlay-amd64-installer

# Create user
echo "**** create user and make folders ****"
groupmod -g 1000 users
useradd -u 911 -U -d /config -s /bin/false swag
usermod -G users swag
mkdir -p \
    /config \
    /default