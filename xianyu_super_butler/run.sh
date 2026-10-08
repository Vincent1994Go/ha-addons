#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

if [ -f "${CONFIG_PATH}" ]; then
    python3 - "${CONFIG_PATH}" > /tmp/xianyu_env.sh <<'PY'
import json
import shlex
import sys

path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as fh:
        data = json.load(fh)
except Exception:
    data = {}

mapping = {
    "admin_username": "ADMIN_USERNAME",
    "admin_password": "ADMIN_PASSWORD",
    "timezone": "TZ",
    "log_level": "LOG_LEVEL",
    "auto_reply_enabled": "AUTO_REPLY_ENABLED",
    "auto_delivery_enabled": "AUTO_DELIVERY_ENABLED",
    "ai_reply_enabled": "AI_REPLY_ENABLED",
    "multiuser_enabled": "MULTIUSER_ENABLED",
    "user_registration_enabled": "USER_REGISTRATION_ENABLED",
    "email_verification_enabled": "EMAIL_VERIFICATION_ENABLED",
}

for key, env_name in mapping.items():
    value = data.get(key)
    if value is None or value == "":
        continue
    if isinstance(value, bool):
        value = "true" if value else "false"
    print("export {0}={1}".format(env_name, shlex.quote(str(value))))
PY
    . /tmp/xianyu_env.sh
fi

export TZ="${TZ:-Asia/Shanghai}"
export LOG_LEVEL="${LOG_LEVEL:-INFO}"

PERSIST_ROOT=/data/xianyu
mkdir -p "${PERSIST_ROOT}/data" "${PERSIST_ROOT}/logs" "${PERSIST_ROOT}/backups" "${PERSIST_ROOT}/uploads"

persist_dir() {
    src="$1"
    dest="$2"
    mkdir -p "${dest}"
    if [ -d "${src}" ] && [ ! -L "${src}" ]; then
        cp -a "${src}/." "${dest}/" 2>/dev/null || true
        rm -rf "${src}"
    fi
    mkdir -p "${src%/*}"
    ln -sfn "${dest}" "${src}"
    mkdir -p "${dest}"
}

persist_dir /app/data    "${PERSIST_ROOT}/data"
persist_dir /app/logs    "${PERSIST_ROOT}/logs"
persist_dir /app/backups "${PERSIST_ROOT}/backups"
persist_dir /app/static/uploads "${PERSIST_ROOT}/uploads"

if [ -f /app/global_config.yml ] && [ ! -L /app/global_config.yml ]; then
    if [ ! -f "${PERSIST_ROOT}/global_config.yml" ]; then
        cp -a /app/global_config.yml "${PERSIST_ROOT}/global_config.yml" 2>/dev/null || true
    fi
    rm -f /app/global_config.yml
    ln -sfn "${PERSIST_ROOT}/global_config.yml" /app/global_config.yml
fi

export DB_PATH="${DB_PATH:-/app/data/xianyu_data.db}"

echo "[xianyu-addon] starting (user=${ADMIN_USERNAME:-admin}, tz=${TZ})"

exec /app/entrypoint.sh
