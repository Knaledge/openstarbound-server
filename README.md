# Plains-of-Pain-Dedicated-Server

[![GitHub](https://img.shields.io/github/license/traxo-xx/plainsofpain-server)](https://github.com/traxo-xx/plainsofpain-server/blob/main/LICENSE)

[![GitHub](https://img.shields.io/badge/Repository-traxo-xx/plainsofpain--server-blue?logo=github)](https://github.com/traxo-xx/plainsofpain-server)

Docker image for the game Plains of Pain. The repo is based on the [enshrouded-server](https://github.com/mornedhels/enshrouded-server) repo made by [mornedhels](https://github.com/mornedhels) and uses supervisor to handle startup, automatic updates and cleanup.

## Creating world files on Windows


> [!IMPORTANT]
> Linux generates slightly different worlds, so they are not perfectly 1:1 same with those
generated on Windows. Because of that, world data has to be generated on
Windows and then copied to the docker host.

* Run the game (or Windows Dedicated Server) with the CLI argument `-cacheTerrainData`
* Create a new world with desired size, seed and map
* Play the single player (let game generate the world), if you are in the world with character, you can safely leave/quit the game
* This process creates files name like:
    * `td_<seed>_<worldSize>_<mapId>.terraindata`
        * example (default): `td_40377_5_0.terraindata`
    * `tmp_wcstrg_localhost_<seed>_<worldSize>_<mapId>_<worldId>.dat`
        * example (default): `tmp_wcstrg_localhost_40377_5_0_0.dat`
* Copy those 2 files into the path where that mount as the folder for the world/map files (`./worldfiles` in the examples further down)
* You can now run the docker container

## Environment Variables

| Variable                          | Required | Default             | Contraints            | Description                                                                                                        | WIP | 
|-----------------------------------|:--------:|---------------------|-----------------------|--------------------------------------------------------------------------------------------------------------------|:---:|
| `SERVER_NAME`                     |          | `Plains of Pain Server` | string                | The name of the server                                                                                             |  ️  |
| `SERVER_PASSWORD`                 |          |                     | string                | The password for the server                                                                                        |     |
| `SERVER_SEED`                 |          | `40377`                    | integer                | The server's map seed                                                                                        |     |
| `SERVER_WORLD_ID`                 |          | `0`                    | integer                | The server's world ID                                                                                        |     |
| `SERVER_DIFFICULTY`               |          | `2`                 | integer                | The server's difficulty setting. (0 = Tourist, 1 = Rookies, 2 = True Wastelander, 3 = Veteran, 4 = Overlord)                                                                                             |  ️  |
| `SERVER_MAP_ID`                     |          | `0` | integer                | ID of the map that should be used (0 = Wasteland v0.4, 1 = Dunes v0.4, 2 = Dunes v0.5)                                                                                             |  ️  |
| `SERVER_WORLD_SIZE`                     |          | `5` | integer                | Size of the server's map (3 = S, 5 = M, 7 = L, 9 = XL, 11 = XXL)                                                                                             |  ️  |
| `SERVER_SLOT_COUNT`               |          | `10`                | integer (1-200)        | Max allowed concurrent players                                                                                     |     |
| `SERVER_PORT`                |          | `7777`             | integer               | The game server's port                                                                                |     |
| `SERVER_QUERYPORT`                |          | `27016`             | integer               | The steam query port for the server                                                                                |     |
| `PUID`                            |          | `4711`              | integer               | The UID to run server as (file permission)                                                                         |     |
| `PGID`                            |          | `4711`              | integer               | The GID to run server as (file permission)                                                                         |     |
| `UPDATE_CRON`                     |          |                     | string (cron format)  | Update game server files cron (eg. `*/30 * * * *` check for updates every 30 minutes)                              |     |
| `UPDATE_CHECK_PLAYERS`            |          | `false`             | boolean (true, false) | Should the update check if someone is connected                                                                    |     |
| `GAME_BRANCH`                     |          | `public`            | string                | Steam branch (eg. testing) of the Plains of Pain server                                                                |     |
| `STEAMCMD_ARGS`                   |          | `validate`          | string                | Additional steamcmd args for the updater                                                                           |     |

All environment Variables prefixed with SERVER are the available config.json options

### Additional Information

* During the update process, the container temporarily requires more disk space (up to 2x the game size).

### Hooks

| Variable           | Description                            | WIP |
|--------------------|----------------------------------------|:---:|
| `BOOTSTRAP_HOOK`   | Command to run after general bootstrap |     |
| `UPDATE_PRE_HOOK`  | Command to run before update           |     |
| `UPDATE_POST_HOOK` | Command to run after update            |     |
| `BACKUP_PRE_HOOK`  | Command to run before backup & cleanup |     |
| `BACKUP_POST_HOOK` | Command to run after backup & cleanup  |     |

The scripts will wait for the hook to resolve/return before continuing.

## Image Tags

| Tag                | Description                              |
|--------------------|------------------------------------------|
| `latest`           | Latest image                             |
| `<version>`        | Pinned image                 (>= 1.x.x)  |
| `dev`              | Dev build                                |

## Ports (default)

| Port      | Description      |
|-----------|------------------|
| 7777/udp  | Server port      |
| 27016/udp | Steam query port |

## Volumes

| Volume                                                           | Description                       |
|------------------------------------------------------------------|-----------------------------------|
| /opt/plainsofpain                                                | Game files (steam download path)  |
| /home/plainsofpain/.config/unity3d/CobraByteDigital/PlainsOfPain | World files and character files   |

**Note:** By default the volumes are created with the UID and GID 4711 (that user should not exist). To change this, set
the environment variables `PUID` and `PGID`.

## Recommended System Requirements

* 50-250 kbps of bandwidth per 1 player
* 4 GB RAM and 2 CPU cores (for small world)
* 8 GB RAM and 4-6 CPU cores (for large world)
* 16-32 GB RAM, 8-16 CPU cores for 200 players on any size world
* Disk: >= 400MB

## Usage

### Docker

```bash
docker run -d --name plainsofpain \
  --hostname plainsofpain \
  --restart=unless-stopped \
  -p 7777:7777/udp \
  -p 27016:27016/udp \
  -v ./game:/opt/plainsofpain \
  -e SERVER_NAME="Plains of Pain Server" \
  -e SERVER_SEED=40377 \
  -e SERVER_WORLD_ID=0 \
  -e SERVER_DIFFICULTY=2 \
  -e SERVER_MAP_ID=0 \
  -e SERVER_WORLD_SIZE=5 \
  -e SERVER_SLOT_COUNT=10 \
  -e SERVER_PASSWORD="secret" \
  -e UPDATE_CRON="*/30 * * * *" \
  -e PUID=4711 \
  -e PGID=4711 \
  ghcr.io/traxo-xx/plainsofpain-server:latest
```

### Docker Compose

```yaml
services:
  plainsofpain:
    image: ghcr.io/traxo-xx/plainsofpain-server:latest
    container_name: plainsofpain
    hostname: plainsofpain
    restart: unless-stopped
    stop_grace_period: 90s
    ports:
      - "7777:7777/udp"
      - "27016:27016/udp"
    volumes:
      - ./game:/opt/plainsofpain
      - ./worldfiles:/home/plainsofpain/.config/unity3d/CobraByteDigital/PlainsOfPain
    environment:
      - SERVER_NAME=Plains of Pain Server
      - SERVER_SEED=40377
      - SERVER_WORLD_ID=0
      - SERVER_DIFFICULTY=2
      - SERVER_MAP_ID=0
      - SERVER_WORLD_SIZE=5
      - SERVER_SLOT_COUNT=10
      - SERVER_PASSWORD=secret
      - UPDATE_CRON=*/30 * * * *
      - PUID=4711
      - PGID=4711
```

**Note:** The volumes are created next to the docker-compose.yml file. If you want to create the volumes in the default
location (eg. /var/lib/docker), you can use the following compose file:

```yaml
services:
  plainsofpain:
    image: ghcr.io/traxo-xx/plainsofpain-server:latest
    container_name: plainsofpain
    hostname: plainsofpain
    restart: unless-stopped
    stop_grace_period: 90s
    ports:
      - "7777:7777/udp"
      - "27016:27016/udp"
    volumes:
      - game:/opt/plainsofpain
      - worldfiles:/home/plainsofpain/.config/unity3d/CobraByteDigital/PlainsOfPain
    environment:
      - SERVER_NAME=Plains of Pain Server
      - SERVER_SEED=40377
      - SERVER_WORLD_ID=0
      - SERVER_DIFFICULTY=2
      - SERVER_MAP_ID=0
      - SERVER_WORLD_SIZE=5
      - SERVER_SLOT_COUNT=10
      - SERVER_PASSWORD=secret
      - UPDATE_CRON=*/30 * * * *
      - PUID=4711
      - PGID=4711

volumes:
  game:
  worldfiles:
```

> [!NOTE]
> The image is also available on Docker Hub: [thatcasualgamingguy/plainsofpain-server](https://hub.docker.com/r/thatcasualgamingguy/plainsofpain-server)

</details>

## Commands

* **Force Update:**
  ```bash
  docker compose exec plainsofpain supervisorctl start plainsofpain-force-update
  ```

## Known Issues

* The server doesn't start or the update fails with following error:
  ```
  Error! App '2278520' state is 0x202 after update job.
  ```
  This means there is probably something wrong with your file permissions. Make sure the UID and GID are correct and the
  files are owned by the correct user.
