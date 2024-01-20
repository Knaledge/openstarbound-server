FROM steamcmd/steamcmd:ubuntu-22@sha256:2c8067c7e1a7ae5d8761d71298317ec4ddbb27df0339aa51febb4c2118e1f67e
LABEL maintainer="docker@mornedhels.de"

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        cabextract \
        curl \
        winbind \
        supervisor \
        cron \
        rsyslog \
        jq

# Install wine
ARG WINE_BRANCH=stable
RUN dpkg --add-architecture i386 \
    && mkdir -pm755 /etc/apt/keyrings \
    && curl -o /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && curl -O --output-dir /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2)/winehq-$(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2).sources \
    && apt update && DEBIAN_FRONTEND="noninteractive" apt -y --install-recommends install winehq-${WINE_BRANCH}

# Install winetricks (unused)
RUN curl -o /tmp/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /tmp/winetricks && install -m 755 /tmp/winetricks /usr/local/bin/winetricks

# MISC
RUN mkdir -p /usr/local/etc /var/log/supervisor /var/run/enshrouded /usr/local/etc/supervisor/conf.d/ /opt/enshrouded /home/enshrouded/.steam \
    && groupadd -g "${PGID:-4711}" -o enshrouded \
    && useradd -g "${PGID:-4711}" -u "${PUID:-4711}" -o --create-home enshrouded \
    && sed -i '/imklog/s/^/#/' /etc/rsyslog.conf \
    && mkdir -m 1777 -p /tmp/.X11-unix \
    && apt autoremove --purge && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./supervisord.conf /etc/supervisor/supervisord.conf
COPY --chmod=755 ./scripts/* /usr/local/etc/enshrouded/

WORKDIR /usr/local/etc/enshrouded
CMD ["/usr/local/etc/enshrouded/bootstrap"]
ENTRYPOINT []
