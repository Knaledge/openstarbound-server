# Starbound + OpenStarbound Dedicated Server (Linux)

## Overview
Docker-centric method of deploying a [Starbound](https://www.playstarbound.com) game server (Linux), weaving in the option to also deploy [OpenStarbound](https://github.com/OpenStarbound/OpenStarbound) - an unaffiliated fan-maintained project that extends the life of Starbound through bug fixes, engine optimizations, and new features introduced to the core Starbound experience.

### Features
- **Core functions** include: game server installation/updates, startup, shutdown, maintenance, and backups
- [Supervisor](https://github.com/Supervisor/supervisor) monitoring of health/liveness for all ***core functions***
- Configurable [cron](https://en.wikipedia.org/wiki/Cron) [schedule](https://crontab.guru/) for many ***core functions*** (e.g., update, backup, restart, etc.)
- Optional checks for player presence ahead of all ***core functions***
- [Hooks](#hooks) before and after ***core functions*** which allow for additional execution of custom commands/scripts
- [Docker-native secrets](https://docs.docker.com/compose/how-tos/use-secrets/) for Steam and game-server credentials (*eliminating* the use of container-accessible repo-tracked files for sensitive data)
- Optional [Steam Guard](https://help.steampowered.com/en/faqs/view/06B0-26E6-2CF8-254C) support (via initial interactive shell session prior to executing ***core functions***)
- Headless runner of game server (i.e. no unnecessary use of xvfb, xterm, etc.)

#### Coming Soon
- Mod support via Steam Workshop API/CDN (i.e. no need to subscribe to mods via Steam client)

### Thanks & Credits
The code and scripts featured in this repo are iterations of original content from [enshrouded-server](https://github.com/mornedhels/enshrouded-server) (by [@mornedhels](https://github.com/mornedhels)) and inspired by its fork [plainsofpain-server](https://github.com/traxo-xx/plainsofpain-server) (by [@traxo-xx](https://github.com/traxo-xx))

Special thanks to the members of the [OpenStarbound Discord community](https://discord.gg/f8B5bWy3bA) for their objective support and feedback during development of the technical aspects of this project

---
## Recommended Host Requirements

* 2 CPU cores & 4GB RAM (minimum)
* 6 CPU cores & 16GB RAM (for active servers with multiple concurrent players)
* Storage: >= 8GB

## Container Image Tags

<!-- > [!NOTE]
> The container image for this repo is also available on Docker Hub: [](() -->

| Tag                | Description                              |
|--------------------|------------------------------------------|
| `latest`           | Latest image                             |
| `<version>`        | Pinned image                 (>= 1.x.x)  |
| `dev-osb`          | Development/preview build (bugs likely)  |

## Environment Variables

> [!NOTE]
> ["Default" values](./scripts/default/defaults) are passed in automatically as outlined below 
> 
> "Required" environment variables will also require a value to be defined

All environment variables prefixed with `SERVER_` are the available Starbound/OpenStarbound server-configuration values

| Variable                          | Required | Default             | Type                  | Description                                                                                                                |
|-----------------------------------|:--------:|---------------------|-----------------------|----------------------------------------------------------------------------------------------------------------------------|
| `PUID`                            |          | `4711`              | integer               | User ID to run the game server processes under (file permission)                                                           |
| `PGID`                            |          | `4711`              | integer               | Group ID to run the game server processes under (file permission)                                                          |
| `LOG_LEVEL`                       |          | `50`                | integer (0-50)        | Filter the logging from Supervisor in container (0=none, 5=fatal, 10=critical, 20=error, 30=warn, 40=info, 50=debug)       |
| `STEAMGUARD_REQUIRED`             |          | `false`             | boolean (true, false) | Enable if Steam Guard authentication is required for the Steam account being used for game server deployment               |
| `STEAMGUARD_TIMEOUT`              |          | `300`               | integer               | Number of seconds to wait for a valid Steam Guard code before exiting (and failing the deployment)                         |
| `GAME_BRANCH`                     |          | `public`            | string                | Steam branch to utilize for the game server                                                                                |
| `STEAMCMD_ARGS`                   |          | `validate`          | string                | Additional SteamCMD arguments to be used when installing/updating the game server                                          |
| `UPDATE_CRON`                     |          | `0 3 * * 0`         | string (cron format)  | Update game server files on a schedule via cron (e.g., `*/30 * * * *` checks for updates every 30 minutes)                 |
| `UPDATE_CHECK_PLAYERS`            |          | `true`              | boolean               | Check if any players are connected to the game server prior to updating the game server                                    |
| `BACKUP_CRON`                     |          | `0 4 * * *`         | string                | Back up game server files on a schedule via cron (e.g., `0 4 * * *` triggers backup every day at 4:00 AM)                  |
| `BACKUP_MAX_COUNT`                |          | `7`                 | integer               | Number of backups retained before oldest backup is overwritten                                                             |
| `SERVER_NAME`                     |          | `Starbound Server`  | string                | Name of the game server                                                                                                    |
| `SERVER_SLOT_COUNT`               |          | `8`                 | integer               | Max allowed concurrent players                                                                                             |
| `SERVER_PORT`                     |          | `21025`             | integer               | Primary networking port used when connecting to the game server                                                            |
| `SERVER_QUERYPORT`                |          | `21025`             | integer               | Networking port used when utilizing the "query port" of the game server                                                    |
| `SERVER_RCON_PORT`                |          | `21026`             | integer               | Networking port used when utilizing the "remote control" functionality of the game server                                  |
| `SERVER_RCON_ENABLED`             |          | `false`             | boolean               | Remote control of the game server available; forced to "false" if `starbound_rcon_password` Docker secret is undefined     |
| `SERVER_CHECK_ASSETS`             |          | `false`             | boolean               | Enable asset checking (not mods); forced to "true" when `USE_OPENSTARBOUND` is "true"                                      |
| `USE_OPENSTARBOUND`               |          | `false`             | boolean               | Enable deployment of OpenStarbound on top of the Starbound game server (updated per `UPDATE_CRON` schedule)                |

## Docker Secrets

> [!IMPORTANT]
> [Docker-native secrets](https://docs.docker.com/compose/how-tos/use-secrets/) are utilized to securely handle Steam credentials and sensitive data for the game server config (e.g., passwords). Unless otherwise [specified](#secrets-storage), each "***Host Secret File***" for each secret ***must*** be created and populated with a value prior to deployment of the game server
> 
> **[Docker Compose](#docker-compose) ***must*** be used to deploy the game server**

#### Steam Credentials

> [!IMPORTANT]
> If [Steam Guard](https://help.steampowered.com/en/faqs/view/06B0-26E6-2CF8-254C) is enabled on the Steam account used for game server deployment, `STEAMGUARD_REQUIRED` ***must*** be set to "true" (default is "false") and the container service ***must*** allow for interactive shell access (e.g., `stdin_open: true` and `tty: true` in [docker-compose](#docker-compose))

For Steam accounts that have Steam Guard enabled, connect to the container's interactive shell to provide a valid Steam Guard code when prompted. The container will wait for a valid Steam Guard code for a configurable period of time, with the number of seconds to wait defined by `STEAMGUARD_TIMEOUT` (default is "300" - i.e. 5 minutes).

> [!WARNING]
> If the `STEAMGUARD_TIMEOUT` period expires before valid entry of a Steam Guard code, the authentication routine will exit, the game server deployment process will terminate, **and the container itself will stop** - *regardless of the container service's `restart` policy*

Successful entry of a valid Steam Guard code will result in the game server installation/update proceeding as usual and the Steam Guard session data being cached in the 'steam-data' [volume](#volumes) defined in [docker-compose](#docker-compose). Provided that the 'steam-data' volume's content remains intact, the game server will be able to install/update for a duration before a new valid Steam Guard code needs to be provided again.

### Secrets Storage

Simply create a directory on the game server's host itself to store the "Host Secret File" - then define the host path to each secret via `docker-compose` ([example](#docker-compose))

| Secret                        | Host Secret File                               | Description                                    | Required File  | Value Required                |
|-------------------------------|------------------------------------------------|------------------------------------------------|:--------------:|:-----------------------------:|
| `steam_username`              | `steam_username.txt`                           | Steam username to utilize with SteamCMD        | Yes            | Yes                           |
| `steam_password`              | `steam_password.txt`                           | Steam password to utilize with SteamCMD        | Yes            | Yes                           |
| `starbound_rcon_password`     | `starbound_rcon_password.txt`                  | Password for RCON access to the game server    | Yes            | No (*if RCON is not desired*) |

## Ports

> [!IMPORTANT]
> Network port values defined in the Docker `ports` section/key usually align with the network ports for the game server

| Port        | Description                        |
|-------------|------------------------------------|
| `21025/tcp` | Game server (primary)              |
| `21025/tcp` | Steam queries                      |
| `21026/tcp` | Game server RCON (remote control)  |

## Volumes

> [!NOTE]
> SteamCMD typically requires approximately 2x the size of the game server in order to update the game server itself

By default the volumes are created with the **PUID** and **PGID** "4711" and may be overridden by defining the environment variables `PUID` and `PGID` via `docker-compose` ([example](#docker-compose))

| Volume                  | Description                                 |
|-------------------------|---------------------------------------------|
| `/opt/starbound`        | Game server files                           |
| `/home/starbound/Steam` | Steam content ('starbound' user directory)  |

## Usage

### Docker Compose

Current [docker-compose.yml](./docker-compose.yml)

```yml
services:
  starbound:
    tty: true                            # Required for Steam Guard support (able to be removed if Steam Guard is disabled on the Steam account)
    stdin_open: true                     # Required for Steam Guard support (able to be removed if Steam Guard is disabled on the Steam account)
    image: ghcr.io/knaledge/openstarbound-server:latest
    container_name: starbound-server
    hostname: starbound
    restart: on-failure:3                # Restart the container up to 3 times on failure
    stop_grace_period: 2m
    cap_add:
      - sys_nice
    ports:
      - "21025:21025/tcp"                # Match with 'SERVER_PORT' value
      - "21026:21026/tcp"                # Match with 'SERVER_RCON_PORT' value
    volumes:
      - /path/to/volume/for/game-data:/opt/starbound
      - /path/to/volume/for/steam-data:/home/starbound/Steam
    secrets:
      - steam_username
      - steam_password
      - starbound_rcon_password
    environment:
      - PUID=4711                        # Docker Process User ID; default is "4711"
      - PGID=4711                        # Docker Process Group ID; default is "4711"
      - UPDATE_CRON=0 3 * * 0            # Default is update every Sunday at 3 AM (server host time)
      - BACKUP_CRON=0 4 * * *            # Default is backup every day at 4 AM (server host time)
      - BACKUP_MAX_COUNT=7               # Default is retain a max of 7 backups before overwriting the oldest
      - LOG_LEVEL=50                     # Default is "50" (debug); 0-100 (0=none, 100=all)  
      - STEAMGUARD_REQUIRED=false        # Default is "false"; set to "true" if the Steam account is protected by Steam Guard
      - STEAMGUARD_TIMEOUT=300           # Default is "300" (seconds); amount of time to wait for a valid Steam Guard code before exiting (and failing the deployment)
      - SERVER_NAME=Starbound Server
      - SERVER_PORT=21025                # Match with 'ports' definition; default is "21025"
      - SERVER_RCON_PORT=21026           # Match with 'ports' definition; default is "21026"
      - SERVER_RCON_ENABLED=false        # Forced to "false" if 'starbound_rcon_password' secret is undefined
      - SERVER_SLOT_COUNT=8
      - SERVER_CHECK_ASSETS=false        # Forced to "true" when 'USE_OPENSTARBOUND' is "true"
      - USE_OPENSTARBOUND=false          # Enable deployment of OpenStarbound on top of the Starbound game server

secrets:
  steam_username:
    file: /path/to/secrets/volume/steam_username.txt
  steam_password:
    file: /path/to/secrets/volume/steam_password.txt
  starbound_rcon_password:
    file: /path/to/secrets/volume/starbound_rcon_password.txt
```

## Additional Commands

#### Force Update
  ```bash
  docker compose exec starbound supervisorctl start starbound-force-update
  ```

## Hooks

> [!NOTE]
> Utilize hooks to perform tasks before/after the primary purpose of each install/update script is finished; use of hooks will cause the related install/update scripts to wait for each hook to resolve/return before continuing

| Variable           | Description                            |
|--------------------|----------------------------------------|
| `BOOTSTRAP_HOOK`   | Command to run after general bootstrap |
| `UPDATE_PRE_HOOK`  | Command to run before update           |
| `UPDATE_POST_HOOK` | Command to run after update            |
| `BACKUP_PRE_HOOK`  | Command to run before backup & cleanup |
| `BACKUP_POST_HOOK` | Command to run after backup & cleanup  |
