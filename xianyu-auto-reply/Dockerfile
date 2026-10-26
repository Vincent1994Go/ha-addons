ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    TZ=Asia/Shanghai \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# ---------- 运行时组件：Redis / Nginx / Supervisor ----------
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        procps \
        tzdata \
        redis-server \
        nginx \
        supervisor; \
    rm -rf /var/lib/apt/lists/*

# ---------- MySQL Server（官方 APT 源，按 Debian 代号选择组件） ----------
# 注意：MySQL 的签名密钥会定期轮换/过期（mysql-2023 已于 2025-10-22 过期），
# 这里同时装入 2023 与 2025 两把公钥；若源仍校验失败则降级为 trusted=yes 继续安装。
RUN set -eux; \
    . /etc/os-release; \
    if [ "${VERSION_CODENAME}" = "bookworm" ]; then \
        MYSQL_COMPONENT="mysql-8.0"; \
    else \
        MYSQL_COMPONENT="mysql-8.4-lts"; \
    fi; \
    MYSQL_SOURCE="https://repo.mysql.com/apt/debian/ ${VERSION_CODENAME} ${MYSQL_COMPONENT}"; \
    install -d -m 0755 /usr/share/keyrings /tmp/mysql-keys; \
    : > /usr/share/keyrings/mysql.gpg; \
    for v in 2023 2025; do \
        if curl -fsSL "https://repo.mysql.com/RPM-GPG-KEY-mysql-${v}" -o "/tmp/mysql-keys/${v}.asc"; then \
            gpg --dearmor --yes -o "/tmp/mysql-keys/${v}.gpg" "/tmp/mysql-keys/${v}.asc"; \
            cat "/tmp/mysql-keys/${v}.gpg" >> /usr/share/keyrings/mysql.gpg; \
        else \
            echo "[build] skip unavailable MySQL GPG key ${v}" >&2; \
        fi; \
    done; \
    printf 'deb [signed-by=/usr/share/keyrings/mysql.gpg] %s\n' "${MYSQL_SOURCE}" \
        > /etc/apt/sources.list.d/mysql.list; \
    printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d; \
    chmod +x /usr/sbin/policy-rc.d; \
    if ! apt-get update; then \
        echo "[build] MySQL 源签名校验失败，改用 trusted=yes 重试" >&2; \
        printf 'deb [trusted=yes] %s\n' "${MYSQL_SOURCE}" > /etc/apt/sources.list.d/mysql.list; \
        apt-get update; \
    fi; \
    apt-get install -y --no-install-recommends mysql-community-server; \
    rm -f /usr/sbin/policy-rc.d; \
    rm -rf /var/lib/apt/lists/* /var/lib/mysql /tmp/mysql-keys

# ---------- 从上游镜像取回前端静态资源与 websocket / scheduler 源码 ----------
COPY --from=registry.cn-shanghai.aliyuncs.com/zhinian-software/xianyu-frontend:latest /usr/share/nginx/html /app/frontend-dist
COPY --from=registry.cn-shanghai.aliyuncs.com/zhinian-software/xianyu-websocket:latest /app/websocket /app/websocket
COPY --from=registry.cn-shanghai.aliyuncs.com/zhinian-software/xianyu-scheduler:latest /app/scheduler /app/scheduler

# ---------- 补齐 websocket / scheduler 相对 backend-web 缺失的依赖 ----------
RUN pip install --no-cache-dir \
        "aiohttp-socks>=0.8.0" \
        "DrissionPage>=4.0.0" \
        "websockets==12.0" \
        "python-socks[asyncio]>=2.0.0" \
        "openai>=1.0.0" \
        "apscheduler>=3.10.0"

# ---------- 运行目录与配置 ----------
RUN set -eux; \
    mkdir -p /app/backend-web/logs /app/websocket/logs /app/scheduler/logs \
             /app/static/uploads /app/backups /app/browser_data /run/mysqld; \
    rm -f /etc/nginx/sites-enabled/default

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY run.sh /run.sh
RUN chmod a+x /run.sh

LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="addon" \
    io.hass.arch="${BUILD_ARCH}"

EXPOSE 9000

CMD ["/run.sh"]
