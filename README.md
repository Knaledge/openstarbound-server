# Starbound + OpenStarbound Dedicated Server (Linux)

Automated deployment of the Linux game server for Starbound - with optional deployment of OpenStarbound. The code and scripts in this are based on (or largely inspired by) on the [enshrouded-server](https://github.com/mornedhels/enshrouded-server) repo made by [mornedhels](https://github.com/mornedhels) and the [plains-of-pain-server](https://github.com/traxo-xx/plainsofpain-server) repo. 

Supervisor handles the startup, shutdown, and maintenance of the game server.

## Environment Variables

> [!NOTE]
> "Default" values are passed in automatically as outlined below. "Required" environment variables will also require a value to be defined.

All environment variables prefixed with `SERVER_` are the available Starbound/OpenStarbound server configuration values

| Variable                          | Required | Default             | Type                  | Description                                                                                                                |
|-----------------------------------|:--------:|---------------------|-----------------------|----------------------------------------------------------------------------------------------------------------------------|
| `PUID`                            |          | `4711`              | integer               | User ID to run the game server processes under (file permission)                                                           |
| `PGID`                            |          | `4711`              | integer               | Group ID to run the game server processes under (file permission)                                                          |
| `GAME_BRANCH`                     |          | `public`            | string                | Steam branch (eg. testing) to utilize for the game server                                                                  |
| `STEAMCMD_ARGS`                   |          | `validate`          | string                | Additional SteamCMD arguments to be used when installing/updating the game server                                          |
| `UPDATE_CRON`                     |          | `0 3 * * 0 `        | string (cron format)  | Update game server files on a schedule via cron (e.g., `*/30 * * * *` checks for updates every 30 minutes)                 |
| `UPDATE_CHECK_PLAYERS`            |          | `true`              | boolean (true, false) | Check if any players are connected to the game server prior to updating the game server                                    |
| `SERVER_NAME`                     |          | `Starbound Server`  | string                | Name of the game server                                                                                                    |
| `SERVER_SLOT_COUNT`               |          | `8`                 | integer               | Max allowed concurrent players                                                                                             |
| `SERVER_PORT`                     |          | `21025`             | integer               | Primary networking port used when connecting to the game server                                                            |
| `SERVER_QUERYPORT`                |          | `21025`             | integer               | Networking port used when utilizing the "query port" of the game server                                                    |
| `SERVER_RCON_PORT`                |          | `21026`             | integer               | Networking port used when utilizing the "remote control" functionality of the game server                                  |
| `SERVER_RCON_ENABLED`             |          | `false`             | boolean               | Remote control of the game server available; forced to "false" if `starbound_rcon_password` Docker secret is undefined     |

## Docker Secrets

> [!IMPORTANT]
> Docker-native secrets are utilized to securely handle Steam credentials and sensitive data for the game server config (e.g., passwords)

Simply create a directory on the storage of the game server's host itself - then define the path to each secret via `docker-compose` (or the command line flag `--secret`)

| Secret                        | Host File                                      | Description                                    |
|-------------------------------|------------------------------------------------|------------------------------------------------|
| `steam_username`              | `steam_username.txt`                           | Steam username to utilize with SteamCMD        |
| `steam_password`              | `steam_password.txt`                           | Steam password to utilize with SteamCMD        |
| `starbound_rcon_password`     | `starbound_rcon_password.txt`                  | Password for RCON access to the game server    |

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

By default the volumes are created with the PUID and PGID "4711". Override this default by defining the environment variables `PUID` and `PGID` via `docker-compose` (or the command line).

| Volume                                                           | Description                                   |
|------------------------------------------------------------------|-----------------------------------------------|
| `/opt/starbound`                                                 | Game server files (including Steam content)   |

### Hooks

> [!NOTE]
> Utilize hooks to perform tasks before/after the primary purpose of each install/update script is finished; use of hooks will cause the related install/update scripts to wait for each hook to resolve/return before continuing

| Variable           | Description                            | WIP |
|--------------------|----------------------------------------|:---:|
| `BOOTSTRAP_HOOK`   | Command to run after general bootstrap |     |
| `UPDATE_PRE_HOOK`  | Command to run before update           |     |
| `UPDATE_POST_HOOK` | Command to run after update            |     |
| `BACKUP_PRE_HOOK`  | Command to run before backup & cleanup |     |
| `BACKUP_POST_HOOK` | Command to run after backup & cleanup  |     |

## Container Image Tags

| Tag                | Description                              |
|--------------------|------------------------------------------|
| `latest`           | Latest image                             |
| `<version>`        | Pinned image                 (>= 1.x.x)  |
| `dev`              | Dev build                                |

## Recommended System Requirements

* 50-250 Kbps of bandwidth per 1 player
* 4 GB RAM and 2 CPU cores (minimum)
* 16 GB RAM and 6 CPU cores (recommended for active servers with multiple concurrent players)
* Disk: >= 8GB

## Usage

### Docker

<!-- > [!NOTE]
> The container image for this repo is also available on Docker Hub: [](() -->

```bash
docker run -d --name starbound-server \
  --hostname starbound \
  --restart=unless-stopped \
  -p 21025:21025/tcp \
  -p 21026:21026/tcp \
  -v ./game:/opt/starbound \
  -e SERVER_NAME="Starbound Server" \
  -e SERVER_SLOT_COUNT=8 \
  -e UPDATE_CRON="*/30 * * * *" \
  -e PUID=4711 \
  -e PGID=4711 \
  ghcr.io/knaledge/openstarbound-server:latest
```

### Docker Compose

> [!NOTE]
> The volumes are created next to the docker-compose.yml file. If you want to create the volumes in the default location (e.g., /var/lib/docker), you can use the following compose file:

## Commands

* **Force Update:**
  ```bash
  docker compose exec plainsofpain supervisorctl start plainsofpain-force-update
  ```
