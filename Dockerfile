FROM alpine:latest

# environment
ENV ARCH=x86_64 \
MIRROR=http://dl-cdn.alpinelinux.org/alpine \
HOME="/root" \
PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
TERM="xterm"

# install base packages
RUN \
 apk add --no-cache \
	bash \
	coreutils \
	curl \
	shadow \
	whoami

# Create user
RUN \
 echo "**** create swag user and make folders ****" && \
 groupmod -g 1000 users && \
 useradd -u 911 -U -d /config -s /bin/false swag && \
 usermod -G users swag && \
 mkdir -p \
	/config \
	/defaults

# Install build dependencies
RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	cargo \
	g++ \
	gcc \
	libffi-dev \
	#openssl-dev \
	python3-dev \
	tar

# Install runtime packages
RUN \
 echo "**** install runtime packages ****" && \
 apk add --no-cache --upgrade \
	ca-certificates \
	fail2ban \
	gnupg \
	memcached \
	nginx 



# Cleanup before deploying
RUN \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 for cleanfiles in *.pyc *.pyo; \
	do \
	find /usr/lib/python3.*  -iname "${cleanfiles}" -exec rm -f '{}' + \
	; done && \
 rm -rf \
	/tmp/* \
	/root/.cache \
	/root/.cargo

# Download dhparam key from https://2ton.com.au/dhtool/
#Get new DHPARAM wget -o /home/florian/tmp/dhparam https://2ton.com.au/dhparam/4096
# copy local files
COPY root/ /

ENTRYPOINT ["/init"]
