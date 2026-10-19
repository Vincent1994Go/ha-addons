#!/bin/sh
set -e

OPTIONS_FILE="/data/options.json"
ENV_FILE="/tmp/lxserver-options.env"

export NODE_ENV="production"
export PORT="9527"
export DATA_PATH="${DATA_PATH:-/data}"
export LOG_PATH="${LOG_PATH:-/data/logs}"
export CONFIG_PATH="${CONFIG_PATH:-/data/config.js}"
export TZ="${TZ:-Asia/Shanghai}"

mkdir -p "${DATA_PATH}" "${LOG_PATH}" "${DATA_PATH}/cache" "${DATA_PATH}/music"

if [ ! -f "${CONFIG_PATH}" ] && [ -f /server/config.js ]; then
    cp /server/config.js "${CONFIG_PATH}"
    echo "[lxserver] initialized ${CONFIG_PATH} from image defaults"
fi

: > "${ENV_FILE}"

if [ -f "${OPTIONS_FILE}" ]; then
    jq -r '
      def q: tostring | @sh;
      def emit($key; $value):
        if $value == null or ($value | tostring) == "" then empty
        else "export \($key)=\($value | q)" end;
      def flag($key; $value):
        if $value == null then empty
        else "export \($key)=\(if $value then "true" else "false" end)" end;

      emit("ADMIN_PASSWORD"; .admin_password),
      emit("SERVER_NAME"; .server_name),
      emit("PLAYER_NAME"; .player_name),
      emit("ADMIN_PATH"; .admin_path),
      emit("PLAYER_PATH"; .player_path),
      flag("ENABLE_WEBPLAYER_AUTH"; .enable_webplayer_auth),
      emit("WEBPLAYER_PASSWORD"; .webplayer_password),
      flag("USER_ENABLE_PATH"; .enable_user_path),
      flag("USER_ENABLE_ROOT"; .enable_user_root),
      emit("MAX_SNAPSHOT_NUM"; .max_snapshot_num),
      emit("LIST_ADD_MUSIC_LOCATION_TYPE"; .list_add_music_location_type),
      flag("ENABLE_CUSTOM_MUSIC_DIR"; .enable_custom_music_dir),
      flag("ENABLE_CACHE_SIZE_LIMIT"; .enable_cache_size_limit),
      emit("CACHE_SIZE_LIMIT"; .cache_size_limit),
      flag("CONFIG_BACKUP_ENABLE"; .config_backup_enable),
      emit("CONFIG_BACKUP_RETENTION_DAYS"; .config_backup_retention_days),
      flag("SUBSONIC_ENABLE"; .subsonic_enable),
      emit("SUBSONIC_PATH"; .subsonic_path),
      flag("SUBSONIC_ONLINE_SEARCH"; .subsonic_online_search),
      emit("SUBSONIC_ONLINE_SEARCH_MODE"; .subsonic_online_search_mode),
      emit("SUBSONIC_ONLINE_SEARCH_SOURCES"; .subsonic_online_search_sources),
      flag("SUBSONIC_QUALITY_ENABLED"; .subsonic_quality_enabled),
      emit("SUBSONIC_QUALITY_PRIORITY"; .subsonic_quality_priority),
      flag("SUBSONIC_CACHE_ON_PLAY"; .subsonic_cache_on_play),
      flag("SUBSONIC_PLAY_CACHE_FIRST"; .subsonic_play_cache_first),
      flag("WEBDAV_ENABLE"; .webdav_enable),
      emit("WEBDAV_URL"; .webdav_url),
      emit("WEBDAV_USERNAME"; .webdav_username),
      emit("WEBDAV_PASSWORD"; .webdav_password),
      emit("WEBDAV_SYNC_PATH"; .webdav_sync_path),
      emit("WEBDAV_BACKUP_PATH"; .webdav_backup_path),
      emit("SYNC_INTERVAL"; .sync_interval),
      emit("BACKUP_INTERVAL"; .backup_interval),
      flag("WEBDAV_EXCLUDE_CACHE"; .webdav_exclude_cache),
      flag("WEBDAV_EXCLUDE_MUSIC"; .webdav_exclude_music),
      flag("PROXY_ALL_ENABLED"; .proxy_all_enabled),
      emit("PROXY_ALL_ADDRESS"; .proxy_all_address),
      emit("PROXY_HEADER"; .proxy_header),
      flag("DISABLE_TELEMETRY"; .disable_telemetry),
      flag("ENABLE_DEBUG"; .enable_debug),
      ((.users // [])[] | select((.username // "") != "") |
        if (.username | test("^[A-Za-z0-9_]+$"))
        then "export LX_USER_\(.username)=\((.password // "") | q)"
        else "# skipped invalid username: \(.username)" end)
    ' "${OPTIONS_FILE}" >> "${ENV_FILE}" \
        || echo "[lxserver] WARN: failed to parse ${OPTIONS_FILE}, using default config" >&2
fi

. "${ENV_FILE}"

if [ ! -e /server/logs ] && [ ! -L /server/logs ]; then
    ln -s "${LOG_PATH}" /server/logs || true
fi
if [ ! -e /server/cache ] && [ ! -L /server/cache ]; then
    ln -s "${DATA_PATH}/cache" /server/cache || true
fi
if [ ! -e /server/music ] && [ ! -L /server/music ]; then
    ln -s "${DATA_PATH}/music" /server/music || true
fi

echo "[lxserver] starting ${SERVER_NAME:-LX Sync Server} (data=${DATA_PATH}, logs=${LOG_PATH}, port=${PORT})"
echo "[lxserver] 播放器: http://<host>:${PORT}${PLAYER_PATH:-/}  管理后台: http://<host>:${PORT}${ADMIN_PATH:-/admin}"
echo "[lxserver] LX Music 同步地址: http://<host>:${PORT}/<用户名>  Subsonic: http://<host>:${PORT}${SUBSONIC_PATH:-/rest}"

cd /server
exec node index.js
