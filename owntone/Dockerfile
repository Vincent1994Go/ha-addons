ARG BUILD_FROM
FROM docker.io/owntone/owntone:latest

# 安装 jq 用于解析配置 (Alpine 使用 apk)
RUN apk add --no-cache jq

# 缓存破坏层 - 每次更新版本时修改
ARG BUILD_VERSION=1.0.2

# 复制启动脚本
COPY run.sh /
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
