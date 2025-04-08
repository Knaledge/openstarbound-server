FROM steamcmd/steamcmd:ubuntu-24
#LABEL org.opencontainers.image.description="Docker image for the game Plains of Pain. The repo is based on the [enshrouded-server](https://github.com/mornedhels/enshrouded-server) repo made by [mornedhels](https://github.com/mornedhels) and uses supervisor to handle startup, automatic updates and cleanup."

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
RUN mkdir -p /usr/local/etc /var/log/supervisor /var/run/starbound /usr/local/etc/supervisor/conf.d/ /opt/starbound /home/starbound/.steam \
    && groupadd -g "${PGID:-4711}" -o starbound \
    && useradd -g "${PGID:-4711}" -u "${PUID:-4711}" -o --create-home starbound \
    && sed -i '/imklog/s/^/#/' /etc/rsyslog.conf \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./supervisord.conf /etc/supervisor/supervisord.conf
COPY --chmod=755 ./scripts/default/* /usr/local/etc/starbound/

WORKDIR /usr/local/etc/starbound
CMD ["/usr/local/etc/starbound/bootstrap"]
ENTRYPOINT []
