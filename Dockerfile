ARG ALPINE_VERSION=3.19
ARG MONERO_VERSION
ARG UID=568
ARG GID=568

####################################################################################################
## Final image
####################################################################################################
FROM alpine:${ALPINE_VERSION}

ARG MONERO_VERSION
ARG UID
ARG GID

RUN apk add --no-cache \
    ca-certificates \
    tzdata

RUN wget --quiet -O /tmp/monero.tar.bz2 "https://downloads.getmonero.org/cli/monero-linux-x64-v${MONERO_VERSION}.tar.bz2" && \
    tar xvf /tmp/monero.tar.bz2 -C /usr/local/bin monerod && \
    rm -f /tmp/monero.tar.bz2 && \
    chmod +x /usr/local/bin/monerod

COPY --chmod=0755 entrypoint.sh /

RUN addgroup -S -g ${GID} monero && \
    adduser -S -H -D -G monero -u ${UID} -g "" -s /sbin/nologin monero && \
    mkdir -p /var/lib/monero && \
    chown -R monero:monero /var/lib/monero

USER monero

ENTRYPOINT ["/entrypoint.sh"]

CMD ["monerod", ""]

EXPOSE 18080
EXPOSE 18081

VOLUME /var/lib/monero

STOPSIGNAL SIGTERM