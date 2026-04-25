ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

# 安装必要的依赖
RUN apk add --no-cache jq ffmpeg alsa-lib avahi dbus

# 下载并安装 OwnTone
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    autoconf \
    automake \
    libtool \
    git \
    pkgconf \
    avahi-dev \
    alsa-lib-dev \
    ffmpeg-dev \
    curl-dev \
    libevent-dev \
    libsoup-dev \
    sqlite-dev \
    libplist-dev \
    json-c-dev && \
    git clone --depth 1 --branch 29.1 https://github.com/owntone/owntone-server.git /tmp/owntone && \
    cd /tmp/owntone && \
    ./autogen.sh && \
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm -rf /tmp/owntone && \
    apk del .build-deps

# 缓存破坏层 - 每次更新版本时修改
ARG BUILD_VERSION=1.0.8

# 复制启动脚本
COPY run.sh /
RUN chmod +x /run.sh

# 数据目录
VOLUME [ "/data" ]

CMD [ "/run.sh" ]