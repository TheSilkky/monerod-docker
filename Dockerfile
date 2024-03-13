ARG DEBIAN_VERSION=12.5
ARG MONERO_VERSION
ARG UID=568
ARG GID=568

####################################################################################################
## Final image
####################################################################################################
FROM debian:${DEBIAN_VERSION}-slim

ARG MONERO_VERSION
ARG UID
ARG GID

RUN apt update && apt install -y \
    --no-install-recommends \
    ca-certificates \ 
    wget \
    bzip2 && \
    apt clean

RUN wget --quiet -O /tmp/monero.tar.bz2 "https://downloads.getmonero.org/cli/monero-linux-x64-v${MONERO_VERSION}.tar.bz2" && \
    tar xvf /tmp/monero.tar.bz2 -C /usr/local/bin "monero-x86_64-linux-gnu-v${MONERO_VERSION}/monerod" && \
    rm -f /tmp/monero.tar.bz2 && \
    chmod +x /usr/local/bin/monerod

COPY --chmod=0755 entrypoint.sh /

RUN addgroup --system --gid ${GID} monero && \
    adduser --system --no-create-home --disabled-password --gid ${GID} --uid ${UID} --gecos "" --shell /sbin/nologin monero && \
    mkdir -p /var/lib/monero && \
    chown -R monero:monero /var/lib/monero

USER monero

ENTRYPOINT ["/entrypoint.sh"]

CMD ["monerod", "--non-interactive", "--data-dir=/var/lib/monero", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=18081", "--confirm-external-bind", "--no-igd"]

EXPOSE 18080
EXPOSE 18081

VOLUME /var/lib/monero

STOPSIGNAL SIGTERM