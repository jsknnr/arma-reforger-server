# arma-reforger-server

[![Static Badge](https://img.shields.io/badge/DockerHub-blue)](https://hub.docker.com/r/sknnr/arma-reforger-server) ![Docker Pulls](https://img.shields.io/docker/pulls/sknnr/arma-reforger-server) [![Static Badge](https://img.shields.io/badge/GitHub-green)](https://github.com/jsknnr/arma-reforger-server) ![GitHub Repo stars](https://img.shields.io/github/stars/jsknnr/arma-reforger-server)

Run Arma Reforger dedicated server in a container. Optionally includes helm chart for running in Kubernetes.

**Disclaimer:** This is not an official image. No support, implied or otherwise is offered to any end user by the author or anyone else. Feel free to do what you please with the contents of this repo.

## Ports

| Port                | Protocol | Default |
| ------------------- | -------- | ------- |
| Game Port           | UDP      | 2001   |
| A2S Port            | UDP      | 17777   |
| RCON Port           | TCP      | 19999   |

## Environment Variables

Defaults will be used if not specified.

| Name              | Description                                                                             | Default                  | Required |
| ----------------- | --------------------------------------------------------------------------------------- | ------------------------ | -------- |
| PUBLIC_ADDRESS | IP address registered in backend       | None                     | False    |
| BIND_ADDRESS | IP address to which the server socket will be bound | "0.0.0.0" | False |
| GAME_PORT | UDP port to which the server socket will be bound | 2001 | False |
| RCON_PORT | RCON protocol TCP port on which the game listens on | 19999 | False |
| RCON_PASSWORD | is required for RCON to start, no spaces, atleast 3 characters long | None | False |
| RCON_BLACKLIST | A comma separated list of commands excluded from execution | None | False |
| RCON_WHITELIST | A comma separated list of commands that can be executed, and no other command is allowed | None | False |
| A2S_PORT | Steam Query UDP port on which game listens to A2S requests | 17777 | False |
| SERVER_CONFIG_FILE | Full name of server config json file (e.g. ServerConfig.json) If the file does not exist it will be created | "ServerConfig.json" | False |
| MAX_FPS | Sets maximum FPS of the server, useful for performance tuning | 30 | False |
| MAX_PLAYERS | Set the maximum amount of players on the server (max 128) | 64 | False |
| SERVER_NAME | The name of the server | "Reforger Server" | False |
| SERVER_PASSWORD | Password to join teh server | None | False |
| ADMINS | Comma separated list of IdentityIds and/or steamIds. They will have their own queue which have priority before normal players when joining the server. Priority queue works only with admins which are specified by IdentityIds | None | False |
| ADMIN_PASSWORD | Defines the server's admin password, allows a server administrator to login and control the server | None | False |
| SCENARIO_ID | The scenario's .conf file path is defined here | "{ECC61978EDCC2B5A}Missions/23_Campaign.conf" | False |
| VISIBLE | Set the visibility of the server in the Server Browser. | True | False |
| CROSSPLATFORM | If set to true, automatically adds "PLATFORM_PC", "PLATFORM_XBL" and "PLATFORM_PSN" to supportedPlatforms if they are missing; does nothing if set to false. | True | False |
| SUPPORTED_PLATFORMS | Comma separated list of platforms which the server accepts, allowing crossplay. Note, PSN does not currently support mods | "PLATFORM_PC,PLATFORM_XBL,PLATFORM_PSN" | False |
| SERVER_MAX_VIEW_DISTANCE | number value, range 500..10000 | 1600 | False |
| SERVER_MIN_GRASS_DISTANCE | Minimum grass distance in meters. If set to 0 no distance is forced upon clients. Range 0/50..150 | 0 | False |
| NETWORK_VIEW_DISTANCE | Maximum network streaming range of replicated entities. range 500..5000 |  1500 | False |
| DISABLE_THIRD_PERSON | Force clients to use the first-person view. | False | False |
| FAST_VALIDATION | Validation of map entities and components loaded on client when it joins, ensuring things match with initial server state. | True | False |
| BATTLEYE | true to enable BattlEye, false to disable it. | True | False |
| QUEUE_MAX_SIZE | Sets maximum size of how many people can be at one time in join queue to the server. Range 0..50 (0 is disabled) | 0 | False |
| MODS_JSON_FILE | Full name of mods json file (e.g. MyModList.json) that contains all the mods for the server. Do not define if using MODS_JSON_B64. If using this setting, you must mount your file to /home/steam/reforger/config in the container. | None | False |
| MODS_JSON_B64 | Advanced option. Base64 encoded string representation of a mods json file. Useful if you don't want to mount the file. Do not define if using MODS_JSON_FILE. This is the only option when using Kubernetes. | None | False |

## Usage

### Mods

To get mods on the server, get your list of mods as JSON from in game mod manager and copy it to clipboard. Create a file called something snazzy like `TheBestDamnMods.json` and paste that block into the file. Now you will have to make 1 tweak, for some reason the game doesn't actually give you valid json lol. Technically what it gives you is a list of multiple json objects, for each mod, but it's not formatted as a list. So at the very top of your file, create a new blank line, and put an open bracket `[` and at the very bottom of the file create a new line at the bottom and put a closing bracket `]`. Now you have valid json, save the file.

#### Getting mods JSON file into container

Option 1: <br>
Make sure your file exists on your container host machine. Set the `MODS_JSON_FILE` variable to the name of your file (e.g. TheBestDamnMods.json) and then mount that file into the container. You will want a `--mount` argument for your docker run command to get the file in. An example: `--mount type=bind,source=/my/path/to/TheBestDamnMods.json,target=/home/steam/reforger/config/TheBestDamnMods.json` where source is the full path to the file on your container host, and target is where the file should go on the container. If the server gives you an error, this likely because the formatting of your file is invalid, double check the formatting and your mounting paths and try again.

Option 2: <br>
This is a more advanced option that does not require mounting the file. Perform the steps mentioned above to get your list of mods and create your file. Once you have your file saved you are going to base64 encode the file. The output should be a single line. If you are on a Unix/Linux machine, you can do this natively, otherwise I am sure there is a web utility out there that will do it for you. Here is an example command to do this on a Unix/Linux based machine: `base64 -w 0 /my/path/to/TheBestDamnMods.json` <br>
The output will be a long string of encoded text. The larger the file, the longer the string. Very carefully copy the entire string, including any special characters at the very end such as `=` or `==`. You need the whole thing. Now paste that as the value of `MODS_JSON_B64` wrapping it in single quotes (e.g. MODS_JSON_B64='alotofwhatappearstoberandomtextbutitsactuallyjustencoded=='). I recommend typing the first single quote, then pasting, then typing the closing single quote. This will get your mods into the server. If this seems a bit too complicated, just do Option 1 (unless you are running in Kubernetes), they both do the same thing at the end of the day.

#### Using your own server config json

The environment variables can create a config for you. However, if you want to use your own config instead, all you need to do is mount it and tell the container which file to look for. Due note, any environment variable above that has a default will override what is in your config file. So if they differ, just pass that environment variable to the container as empty (e.g. SERVER_NAME='') and it will not override what is in your file. <br>
steps: <br>

1) Mount your config as a bind mount, something like this: `--mount type=bind,source=/my/local/path/to/MyServerConfig.json,target=/home/steam/reforger/config/MyServerConfig.json`
2) Set the SERVER_CONFIG_FILE variable to match your file name: `SERVER_CONFIG_FILE='MyServerConfig.json'`
3) Optionally, any default values you do not want to override in your config file, set them to empty. Example: `SERVER_NAME=''`

### Docker

To run the container in Docker, run the following command, modifying for your preference and situation:

```bash
docker volume create reforger-data
docker run \
  --detach \
  --name reforger-server \
  --mount type=volume,source=reforger-data,target=/home/steam/reforger \
  --mount type=bind,source=/my/local/path/to/Mods.json,target=/home/steam/reforger/config/Mods.json \ # If using mods
  --publish 2001:2001/udp \
  --publish 17777:17777/udp \
  --publish 19999:19999/tcp \
  --env=MODS_JSON_FILE='Mods.json' \ # If using mods
  --env=SERVER_NAME='My Awesome Reforger Server' \
  --env=SERVER_PASSWORD='PleaseChangeMe' \ # If you want a private server
  --env=ADMINS='1234567,ABCDEFG,ONEFISHTWOFISH'
  --env=ADMIN_PASSWORD='AdminPleaseChangeMe' \
  --env=GAME_PORT='2001' \ # Not necessary if you do not change the default, otherwise match publish port
  --env=A2S_PORT='17777' \ # Not necessary if you do not change the default, otherwise match publish port
  --env=RCON_PORT='19999' \ # Not necessary if you do not change the default, otherwise match publish port
  --env=RCON_PASSWORD='RCONPleaseChangeMe' \ # Only necessary if you want to enable RCON
  sknnr/arma-reforger-server:latest
```

### Docker Compose

To user Docker Compose to launch the container, review the following examples:

To bring the container up:

```bash
docker-compose up -d
```

To bring the container down:

```bash
docker-compose down
```

compose.yaml file:

```yaml
version: "3.8"
services:
  reforger:
    image: sknnr/arma-reforger-server:latest
    ports:
      - "2001:2001/udp"
      - "17777:17777/udp"
      - "19999:19999/tcp"
    environment:
      - SERVER_NAME='My Awesome Reforger Server'
      - SERVER_PASSWORD='PleaseChangeMe'
      - ADMIN_PASSWORD='AdminPleaseChangeMe'
      - ADMINS='1234567,ABCDEFG,ONEFISHTWOFISH'
      - MODS_JSON_FILE='Mods.json'
      - GAME_PORT='2001'
      - A2S_PORT='17777'
      - RCON_PORT='19999'
      - RCON_PASSWORD='RCONPleaseChangeMe'
    volumes:
      - reforger-data:/home/steam/reforger
      - /my/path/to/Mods.json:/home/steam/reforger/config/Mods.json

volumes:
  reforger-data:  # Named volume
```

### Podman

To run the container in Podman, run the following command, modifying for your preference and situation:

```bash
podman volume create reforger-data
podman run \
  --detach \
  --name reforger-server \
  --mount type=volume,source=reforger-data,target=/home/steam/reforger \
  --mount type=bind,source=/my/local/path/to/Mods.json,target=/home/steam/reforger/config/Mods.json \ # If using mods
  --publish 2001:2001/udp \
  --publish 17777:17777/udp \
  --publish 19999:19999/tcp \
  --env=MODS_JSON_FILE='Mods.json' \ # If using mods
  --env=SERVER_NAME='My Awesome Reforger Server' \
  --env=SERVER_PASSWORD='PleaseChangeMe' \ # If you want a private server
  --env=ADMINS='1234567,ABCDEFG,ONEFISHTWOFISH'
  --env=ADMIN_PASSWORD='AdminPleaseChangeMe' \
  --env=GAME_PORT='2001' \ # Not necessary if you do not change the default, otherwise match publish port
  --env=A2S_PORT='17777' \ # Not necessary if you do not change the default, otherwise match publish port
  --env=RCON_PORT='19999' \ # Not necessary if you do not change the default, otherwise match publish port
  --env=RCON_PASSWORD='RCONPleaseChangeMe' \ # Only necessary if you want to enable RCON
  docker.io/sknnr/arma-reforger-server:latest
```

### Kubernetes

I've built a Helm chart and have included it in the `helm` directory within this repo. Modify the `values.yaml` file to your liking and install the chart into your cluster. Be sure to create and specify a namespace as I did not include a template for provisioning a namespace. For mods, you will want to use the `MODS_JSON_B64` environment variable option.

The chart in this repo is also hosted in my helm-charts repository [here](https://jsknnr.github.io/helm-charts)

To install this chart from my helm-charts repository:

```bash
helm repo add jsknnr https://jsknnr.github.io/helm-charts
helm repo update
```

To install the chart from the repo:

```bash
helm install reforger jsknnr/arma-reforger-server --values myvalues.yaml
# Where myvalues.yaml is your copy of the Values.yaml file with the settings that you want
```

## FAQ

**Q:** Can you change and or make the user and group IDs configurable? \
**A:** Short answer, no I will not. Longer answer, for security reasons it is best that containers have UID/GIDs at or above 10000 to avoid collision with container host UID/GIDs. To make this configurable, the container would have to start as root and then later change to the desired user... this is also a security concern. If you *really* need to change this, just take my repo and build your own image with IDs you prefer. Just change the build args in the Containerfile.

**Q:** Can you release an ARM64 based image? \
**A:** No. Until the devs release ARM compiled server binaries I won't do this (otherwise requires some sort of emulation, performance cost, what's the point).

**Q:** I can't connect to my server, what is wrong? \
**A:** This is no fault of my image. You need to double check settings on your router and on your container host. Check and then double check firewall rules, dnat/port forwarding rules, etc. If you are still having issues, it is possible that your internet provider (ISP) is using CGNAT (carrier-grade NAT) which can make it really hard if not impossible to host internet facing services from your local network. Call them and discuss.

**Q:** I don't see my server on the in-game browser, what is wrong? \
**A:** Check your network settings, as listed above. Make sure that you have `VISIBLE` set to `true`.
