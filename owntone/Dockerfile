ARG BUILD_FROM
FROM $BUILD_FROM

# 安装必要的依赖
RUN apk add --no-cache jq ffmpeg alsa-lib libavahi-client

# 下载并安装 OwnTone
RUN apk add --no-cache --virtual .build-deps \n    build-base \n    autoconf \n    automake \n    libtool \n    git \n    pkgconf \n    avahi-dev \n    alsa-lib-dev \n    ffmpeg-dev \n    libcurl-dev \n    libevent-dev \n    libsoup-dev \n    sqlite-dev \n    libplist-dev \n    json-c-dev \n    && git clone --depth 1 --branch 29.1 https://github.com/owntone/owntone-server.git /tmp/owntone \n    && cd /tmp/owntone \n    && ./autogen.sh \n    && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \n    && make -j$(nproc) \n    && make install \n    && cd / \n    && rm -rf /tmp/owntone \n    && apk del .build-deps

# 缓存破坏层 - 每次更新版本时修改
ARG BUILD_VERSION=1.0.4

# 复制启动脚本
COPY run.sh /
RUN chmod +x /run.sh

# 数据目录
VOLUME [ "/data" ]

CMD [ "/run.sh" ]