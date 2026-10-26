#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

# ---------------- 1. 读取 addon 配置 ----------------
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
    "timezone": "TZ",
    "log_level": "LOG_LEVEL",
    "mysql_password": "MYSQL_PASSWORD",
    "redis_password": "REDIS_PASSWORD",
    "auto_start_websocket": "AUTO_START_WEBSOCKET",
    "auto_start_crawl_jobs": "AUTO_START_CRAWL_JOBS",
    "max_captcha_concurrent": "MAX_CAPTCHA_CONCURRENT",
    "browser_headless": "BROWSER_HEADLESS",
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

# ---------------- 2. 运行参数 ----------------
export TZ="${TZ:-Asia/Shanghai}"
export LANG=C.UTF-8
export ENVIRONMENT=production
export LOG_LEVEL="${LOG_LEVEL:-INFO}"
export SQL_ECHO=false

export MYSQL_HOST=127.0.0.1
export MYSQL_PORT=3306
export MYSQL_USER=xianyu
export MYSQL_PASSWORD="${MYSQL_PASSWORD:-xianyu@2026}"
export MYSQL_DATABASE=xianyu_data

export REDIS_HOST=127.0.0.1
export REDIS_PORT=6379
export REDIS_PASSWORD="${REDIS_PASSWORD:-xianyu@2026}"
export REDIS_DB=0

export DB_POOL_SIZE=800
export DB_MAX_OVERFLOW=150
export REDIS_POOL_SIZE=800

export HOST=0.0.0.0
export BACKEND_WEB_PORT=8089
export WEBSOCKET_PORT=8090
export SCHEDULER_PORT=8091

export BACKEND_WEB_SERVICE_URL=http://127.0.0.1:8089
export WEBSOCKET_SERVICE_URL=http://127.0.0.1:8090
export SCHEDULER_SERVICE_URL=http://127.0.0.1:8091
export FRONTEND_SERVICE_URL=http://127.0.0.1:9000

export CORS_ORIGINS='*'
export ACCESS_TOKEN_EXPIRE_MINUTES=1440
export REFRESH_TOKEN_EXPIRE_MINUTES=10080

export STATIC_DIR=/app/static
export BACKUP_DIR=/app/backups

export AUTO_START_WEBSOCKET="${AUTO_START_WEBSOCKET:-true}"
export AUTO_START_CRAWL_JOBS="${AUTO_START_CRAWL_JOBS:-true}"
export MAX_CAPTCHA_CONCURRENT="${MAX_CAPTCHA_CONCURRENT:-3}"
export BROWSER_HEADLESS="${BROWSER_HEADLESS:-true}"

export CAPTCHA_DRISSIONPAGE_FALLBACK_ENABLED=false
export CAPTCHA_DRISSIONPAGE_TIMEOUT=25
export CAPTCHA_DRISSIONPAGE_HEADLESS="${BROWSER_HEADLESS:-true}"

export REDELIVERY_INTERVAL=5
export RATE_INTERVAL=20

export CARD_DOCK_BASE_URL=http://backend.zhinianboke.com
export EXTERNAL_API_KEY=zhinian_bk
export REMOTE_OFFICIAL_BASE_URL=https://xy.zhinianboke.com
export ENABLE_REMOTE_ADS=true
export ENABLE_REMOTE_ANNOUNCEMENTS=true
export ENABLE_REMOTE_POPUP_ANNOUNCEMENTS=true

export PYTHONPATH=/app
export PYTHONUNBUFFERED=1
export PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# ---------------- 3. 持久化目录 ----------------
PERSIST_ROOT=/data/xianyu
mkdir -p \
    "${PERSIST_ROOT}/mysql" \
    "${PERSIST_ROOT}/redis" \
    "${PERSIST_ROOT}/static/uploads" \
    "${PERSIST_ROOT}/backups" \
    "${PERSIST_ROOT}/browser_data"

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

persist_dir /app/static "${PERSIST_ROOT}/static"
persist_dir /app/backups "${PERSIST_ROOT}/backups"
persist_dir /app/browser_data "${PERSIST_ROOT}/browser_data"

# ---------------- 4. Redis 配置 ----------------
cat > /etc/redis/redis-addon.conf <<EOF
bind 127.0.0.1
protected-mode yes
port 6379
daemonize no
dir /data/xianyu/redis
requirepass "${REDIS_PASSWORD}"
maxmemory 256mb
maxmemory-policy allkeys-lru
appendonly yes
logfile ""
EOF

# ---------------- 5. MySQL 初始化 ----------------
MYSQL_MARKER="${PERSIST_ROOT}/.db_password"
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

need_bootstrap=1
if [ -d "${PERSIST_ROOT}/mysql/mysql" ] && [ -f "${MYSQL_MARKER}" ] \
   && [ "$(cat "${MYSQL_MARKER}")" = "${MYSQL_PASSWORD}" ]; then
    need_bootstrap=0
    echo "[init] existing database detected, skipping bootstrap"
fi

if [ "${need_bootstrap}" = "1" ]; then
    chown -R mysql:mysql "${PERSIST_ROOT}/mysql"

    if [ ! -d "${PERSIST_ROOT}/mysql/mysql" ]; then
        # 上次初始化可能中途失败，留下半成品目录；--initialize-insecure 要求目录为空
        if [ -n "$(ls -A "${PERSIST_ROOT}/mysql" 2>/dev/null)" ]; then
            echo "[init] incomplete MySQL data directory found, cleaning up ..."
            find "${PERSIST_ROOT}/mysql" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
        fi
        echo "[init] initializing MySQL data directory ..."
        mysqld --initialize-insecure --user=mysql --datadir="${PERSIST_ROOT}/mysql"
    fi

    echo "[init] bootstrapping database and user ..."
    # 注意：上面 export 的 MYSQL_HOST 会被 mysql/mysqladmin 客户端当作默认主机，
    # 一旦主机不是 localhost 客户端就会强制走 TCP 而忽略 --socket。因此这里用
    # env -u 屏蔽相关变量，并用 --protocol=socket 强制走本地 socket。
    BOOT_SOCK=/run/mysqld/mysqld-init.sock
    BOOT_LOG=/tmp/mysql-bootstrap.log
    : > "${BOOT_LOG}"

    mysqld --user=mysql \
           --datadir="${PERSIST_ROOT}/mysql" \
           --socket="${BOOT_SOCK}" \
           --pid-file=/run/mysqld/mysqld-init.pid \
           --skip-networking \
           --mysqlx=OFF >>"${BOOT_LOG}" 2>&1 &
    BOOT_PID=$!

    boot_client() {
        _prog="$1"
        shift
        env -u MYSQL_HOST -u MYSQL_TCP_PORT -u MYSQL_UNIX_PORT -u MYSQL_PWD \
            "${_prog}" --protocol=socket --socket="${BOOT_SOCK}" --user=root "$@"
    }

    for _ in $(seq 1 120); do
        boot_client mysqladmin ping >/dev/null 2>&1 && break
        if ! kill -0 "${BOOT_PID}" 2>/dev/null; then
            break
        fi
        sleep 1
    done

    if ! boot_client mysqladmin ping >/dev/null 2>&1; then
        echo "[init] ERROR: MySQL failed to start for bootstrap" >&2
        cat "${BOOT_LOG}" >&2 || true
        exit 1
    fi

    boot_client mysql <<SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'127.0.0.1' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER '${MYSQL_USER}'@'127.0.0.1' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'127.0.0.1';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

    boot_client mysqladmin shutdown || true
    wait "${BOOT_PID}" 2>/dev/null || true
    rm -f "${BOOT_SOCK}" /run/mysqld/mysqld-init.pid "${BOOT_LOG}"
    printf '%s' "${MYSQL_PASSWORD}" > "${MYSQL_MARKER}"
fi

echo "[init] starting services via supervisord ..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
