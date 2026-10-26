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
RUN set -eux; \
    . /etc/os-release; \
    if [ "${VERSION_CODENAME}" = "bookworm" ]; then \
        MYSQL_COMPONENT="mysql-8.0"; \
    else \
        MYSQL_COMPONENT="mysql-8.4-lts"; \
    fi; \
    install -d -m 0755 /usr/share/keyrings; \
    curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 -o /usr/share/keyrings/mysql.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/mysql.gpg] https://repo.mysql.com/apt/debian/ ${VERSION_CODENAME} ${MYSQL_COMPONENT}" \
        > /etc/apt/sources.list.d/mysql.list; \
    printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d; \
    chmod +x /usr/sbin/policy-rc.d; \
    apt-get update; \
    apt-get install -y --no-install-recommends mysql-community-server; \
    rm -f /usr/sbin/policy-rc.d; \
    rm -rf /var/lib/apt/lists/* /var/lib/mysql

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
