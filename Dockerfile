FROM alpine:latest

# environment
ENV ARCH=x86_64
ENV MIRROR=http://dl-cdn.alpinelinux.org/alpine
ENV HOME="/root"


# install base packages
RUN \
 apk add --no-cache \
	bash \
	coreutils \
	curl \
	shadow

# Create user
RUN \
 echo "**** create abc user and make folders ****" && \
 groupmod -g 1000 users && \
 useradd -u 911 -U -d /config -s /bin/false abc && \
 usermod -G users abc && \
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

# copy local files
COPY root/ /

ENTRYPOINT ["/init"]
