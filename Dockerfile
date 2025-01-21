FROM steamcmd/steamcmd:ubuntu-24@sha256:ea9f460c83e400c6061ea420cc443ac7dfc4ebdaf8636b687097d43123d8d170
LABEL maintainer="get.to.the.gone@gmail.com"
LABEL org.opencontainers.image.description="Docker image for the game Plains of Pain. The repo is based on the [enshrouded-server](https://github.com/mornedhels/enshrouded-server) repo made by [mornedhels](https://github.com/mornedhels) and uses supervisor to handle startup, automatic updates and cleanup."

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        cabextract \
        curl \
        winbind \
        supervisor \
        cron \
        rsyslog \
        jq \
        lsof \
        zip \
        python3 \
        python3-pip \
    && apt autoremove --purge && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# MISC
RUN mkdir -p /usr/local/etc /var/log/supervisor /var/run/plainsofpain /usr/local/etc/supervisor/conf.d/ /opt/plainsofpain /home/plainsofpain/.steam/sdk32 /home/plainsofpain/.steam/sdk64 /home/plainsofpain/.config/unity3d/CobraByteDigital/PlainsOfPain \
    && groupadd -g "${PGID:-4711}" -o plainsofpain \
    && useradd -g "${PGID:-4711}" -u "${PUID:-4711}" -o --create-home plainsofpain \
    && ln -f /root/.steam/sdk32/steamclient.so /home/plainsofpain/.steam/sdk32/steamclient.so \
    && ln -f /root/.steam/sdk64/steamclient.so /home/plainsofpain/.steam/sdk64/steamclient.so \
    && sed -i '/imklog/s/^/#/' /etc/rsyslog.conf \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./supervisord.conf /etc/supervisor/supervisord.conf
COPY --chmod=755 ./scripts/default/* /usr/local/etc/plainsofpain/

WORKDIR /usr/local/etc/plainsofpain
CMD ["/usr/local/etc/plainsofpain/bootstrap"]
ENTRYPOINT []
