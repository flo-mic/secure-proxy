FROM alpine:latest as rootfs-stage

# environment
ENV ARCH=x86_64
ENV MIRROR=http://dl-cdn.alpinelinux.org/alpine
ENV HOME="/root"


# install base packages
RUN \
 apk add --no-cache \
	bash \
	coreutils \
	curl

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
	openssl-dev \
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
	nginx \
	nginx-mod-http-brotli \
	nginx-mod-http-dav-ext \
	nginx-mod-http-echo \
	nginx-mod-http-fancyindex \
	nginx-mod-http-geoip2 \
	nginx-mod-http-headers-more \
	nginx-mod-http-image-filter \
	nginx-mod-http-nchan \
	nginx-mod-http-perl \
	nginx-mod-http-redis2 \
	nginx-mod-http-set-misc \
	nginx-mod-http-upload-progress \
	nginx-mod-http-xslt-filter \
	nginx-mod-mail \
	nginx-mod-rtmp \
	nginx-mod-stream \
	nginx-mod-stream-geoip2 \
	nginx-vim \
	py3-cryptography \
	py3-future \
	py3-pip \
	whois


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
