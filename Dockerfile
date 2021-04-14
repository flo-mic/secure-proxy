FROM alpine:latest

# environment settings
ENV DHLEVEL=2048 ONLY_SUBDOMAINS=false AWS_CONFIG_FILE=/config/dns-conf/route53.ini
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	cargo \
	g++ \
	gcc \
	libffi-dev \
	openssl-dev \
	python3-dev

RUN \
 echo "**** install runtime packages ****" && \
 apk add --no-cache --upgrade \
	curl \
	fail2ban \
	gnupg \
	memcached \
	nginx

# add local files
COPY root/ /
