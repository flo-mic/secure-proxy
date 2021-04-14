FROM alpine:latest
LABEL maintainer="flo-mic"
RUN apk add nginx
RUN mkdir -p /run/nginx
RUN touch /run/nginx/nginx.pid
RUN adduser -D -g 'www' www
RUN mkdir /www 
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www
COPY root/ /
RUN ["./usr/sbin/nginx"]