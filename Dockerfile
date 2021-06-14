FROM alpine:latest
MAINTAINER Neil Millard <neil@neilmillard.com>
ENV GLIBC_VERSION 2.23-r1
RUN mkdir -p /opt/btsync
COPY btsync /opt/btsync/btsync
COPY btsync.conf /btsync/config/btsync.conf
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN chmod +x /opt/btsync/btsync && \
    apk add --update curl ca-certificates bash openssl-dev miniupnpc && \
    curl -o /tmp/glibc.apk -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
    apk add --allow-untrusted /tmp/glibc.apk && \
    curl -o /tmp/glibc-bin.apk -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
    apk add --allow-untrusted /tmp/glibc-bin.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc/usr/lib && \
    rm -rf /tmp/* /var/cache/apk/* &&  \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    mkdir -p /btsync/data && mkdir -p /btsync/config && mkdir -p /btsync/folders && \ 
    mkdir -p /var/run/btsync

EXPOSE 8888 55555 55555/udp

VOLUME /btsync

ENTRYPOINT ["/opt/btsync/btsync"]
CMD ["--nodaemon","--config","/btsync/config/btsync.conf"]
