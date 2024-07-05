FROM steamcmd/steamcmd:ubuntu-24@sha256:748e3db77cccc188276640bf1849c8c10325d7ff264a5ba8399362bd54d48f5a
LABEL maintainer="get.to.the.gone@gmail.com"

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
