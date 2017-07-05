FROM alpine:latest
LABEL maintainer="hackaday <hackaday@coz.moe>"

ENV LANG C.UTF-8

# Add s6-overlay
ENV S6_OVERLAY_VERSION=v1.18.1.5

RUN set -ex \
        && apk add --no-cache --virtual .fetch-deps \
                curl \
        && curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
                | tar xfz - -C / \
        && rm -f s6-overlay-amd64.tar.gz \
        && apk del .fetch-deps

# build and install
RUN set -ex \
        && apk add --update --no-cache --virtual .build-deps \
                automake \
                autoconf \
                openssl-dev \
                curl-dev \
                git \
                build-base \
        && cd /opt \
        && git clone https://github.com/OhGodAPet/cpuminer-multi \
        && cd cpuminer-multi \
        && ./autogen.sh \
        && CFLAGS="-O3" ./configure \
        && make \
        && apk del .build-deps

COPY src/ .

# ssh
RUN apk add --update --no-cache openssh

RUN set -ex \
        && ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa \
        && ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa \
        && mkdir -p /var/run/sshd

RUN echo 'root:root' | chpasswd

EXPOSE 22

ENV USERNAME 'yqt-0314@126.com'
ENV POOL 'xmr.pool.minergate.com:45560'
ENV THREAD_NUM 8

WORKDIR /

ENTRYPOINT ["/init"]