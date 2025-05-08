#!/bin/bash

# Quick function to generate a timestamp
timestamp () {
  date +"%Y-%m-%d %H:%M:%S,%3N"
}

# Function to easily call the config editor
config_editor () {
  python3 /home/steam/config_editor.py "$@"
}

# Function to start Arma Reforger Dedicated Server
start () {
    launch_args="-config ${REFORGER_PATH}/config/${SERVER_CONFIG_FILE} -profile ${REFORGER_PATH}/profile -addonDownloadDir ${REFORGER_PATH}/workshop -addonsDir ${REFORGER_PATH}/workshop -backendlog -nothrow -maxFPS ${MAX_FPS} ${EXTRA_LAUNCH_ARGS}"

    echo "$(timestamp) INFO: Starting Arma Reforger Dedicated Server"
    "${REFORGER_PATH}/ArmaReforgerServer" "${launch_args}"
}

# Function to update Arma Reforger Dedicated Server
update() {
    echo "$(timestamp) INFO: Updating Arma Reforger Dedicated Server"
    "${STEAMCMD_PATH}/steamcmd.sh" +force_install_dir "${REFORGER_PATH}" +login anonymous +app_update "${STEAM_APP_ID}" validate +quit
}

# Function to edit server configuration
modify_server_config () {
  if [ -f "${REFORGER_PATH}/config/${SERVER_CONFIG_FILE}" ]; then
    echo "$(timestamp) WARN: Server configuration file not found at ${REFORGER_PATH}/config/${SERVER_CONFIG_FILE}"
    echo "$(timestamp) INFO: Creating new server configuration file"
    cp /home/steam/example_server_config.json "${REFORGER_PATH}/config/${SERVER_CONFIG_FILE}"
  else
    echo "$(timestamp) INFO: Server configuration file not at ${REFORGER_PATH}/config/${SERVER_CONFIG_FILE}"
  fi

  # Path to server configuration json file
  CONFIG_PATH="${REFORGER_PATH}/config/${SERVER_CONFIG_FILE}"

  echo "$(timestamp) INFO: Updating configuration file from environment variables"

  # Perform some validation on our MODS environment vars

  # MODS_JSON_FILE and MODS_JSON_B64 are mutually exclusive
  if [ -n "${MODS_JSON_FILE}" ] && [ -n "${MODS_JSON_B64}" ]; then
    echo "$(timestamp) ERROR: MODS_JSON_FILE and MODS_JSON_B64 are mutually exclusive, use one or the other"
    exit 1
  fi
  # Check if MODS_JSON_FILE is set and the file exists
  if [ -n "${MODS_JSON_FILE}" ] && [ ! -f "${REFORGER_PATH}/config/${MODS_JSON_FILE}" ]; then
    echo "$(timestamp) ERROR: Mods JSON file not found at ${REFORGER_PATH}/config/${MODS_JSON_FILE}"
    echo "Ensure that the file is mounted correctly to ${REFORGER_PATH}/config and that MODS_JSON_FILE matches the filename."
    exit 1
  fi
  # Check if MODS_JSON_B64 is set and is a valid base64 string
  if [ -n "${MODS_JSON_B64}" ]; then
    if ! echo "${MODS_JSON_B64}" | base64 --decode &>/dev/null; then
      echo "$(timestamp) ERROR: MODS_JSON_B64 is not valid base64"
      exit 1
    fi
  fi

  # Begin checking for environment variables and updating the config file

  if [ -n "${PUBLIC_ADDRESS}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "publicAddress" -v "${PUBLIC_ADDRESS}"
  fi

  if [ -n "${BIND_ADDRESS}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "bindAddress" -v "${BIND_ADDRESS}"
    config_editor -c "${CONFIG_PATH}" -k "a2s.address" -v "${BIND_ADDRESS}"
  fi

  if [ -n "${GAME_PORT}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "bindPort" -v "${GAME_PORT}"
    config_editor -c "${CONFIG_PATH}" -k "publicPort" -v "${GAME_PORT}"
  fi

  if [ -n "${RCON_PORT}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "rcon.port" -v "${RCON_PORT}"
  fi

  if [ -n "${RCON_PASSWORD}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "rcon.password" -v "${RCON_PASSWORD}"
  fi

  if [ -n "${RCON_ADDRESS}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "rcon.address" -v "${RCON_ADDRESS}"
  fi

  if [ -n "${RCON_BLACKLIST}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "rcon.blacklist" -v "${RCON_BLACKLIST}"
  fi

  if [ -n "${RCON_WHITELIST}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "rcon.whitelist" -v "${RCON_WHITELIST}"
  fi

  if [ -n "${A2S_PORT}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "a2s.port" -v "${A2S_PORT}"
  fi

  if [ -n "${MAX_PLAYERS}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.maxPlayers" -v "${MAX_PLAYERS}"
  fi

  if [ -n "${SERVER_NAME}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.name" -v "${SERVER_NAME}"
  fi

  if [ -n "${SERVER_PASSWORD}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.password" -v "${SERVER_PASSWORD}"
  fi

  if [ -n "${ADMIN_PASSWORD}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.passwordAdmin" -v "${ADMIN_PASSWORD}"
  fi

  if [ -n "${ADMINS}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.admins" -v "${ADMINS}"
  fi

  if [ -n "${SCENARIO_ID}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.scenarioId" -v "${SCENARIO_ID}"
  fi

  if [ -n "${VISIBLE}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.visible" -v "${VISIBLE}"
  fi

  if [ -n "${CROSSPLATFORM}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.crossPlatform" -v "${CROSSPLATFORM}"
  fi

  if [ -n "${SUPPORTED_PLATFORMS}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.supportedPlatforms" -v "${SUPPORTED_PLATFORMS}"
  fi

  if [ -n "${SERVER_MAX_VIEW_DISTANCE}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.gameProperties.serverMaxViewDistance" -v "${SERVER_MAX_VIEW_DISTANCE}"
  fi

  if [ -n "${SERVER_MIN_GRASS_DISTANCE}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.gameProperties.serverMinGrassDistance" -v "${SERVER_MIN_GRASS_DISTANCE}"
  fi

  if [ -n "${NETWORK_VIEW_DISTANCE}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.gameProperties.networkViewDistance" -v "${NETWORK_VIEW_DISTANCE}"
  fi

  if [ -n "${DISABLE_THIRD_PERSON}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.gameProperties.disableThirdPerson" -v "${DISABLE_THIRD_PERSON}"
  fi

  if [ -n "${FAST_VALIDATION}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.gameProperties.fastValidation" -v "${FAST_VALIDATION}"
  fi

  if [ -n "${BATTLEYE}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.gameProperties.battlEye" -v "${BATTLEYE}"
  fi

  if [ -n "${MODS_JSON_FILE}" ]; then
    # game.mods expects the value to be base64 encoded
    encoded_mods_file=$(base64 -w 0 "${REFORGER_PATH}/config/${MODS_JSON_FILE}")
    config_editor -c "${CONFIG_PATH}" -k "game.mods" -v "${encoded_mods_file}"
  fi

  if [ -n "${MODS_JSON_B64}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "game.mods" -v "${MODS_JSON_B64}"
  fi

  if [ -n "${QUEUE_MAX_SIZE}" ]; then
    config_editor -c "${CONFIG_PATH}" -k "operating.joinQueue.maxSize" -v "${QUEUE_MAX_SIZE}"
  fi
}

# Call to update, modify config, and start the server
update
modify_server_config
start
 