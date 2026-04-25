FROM debian:12-slim

ARG BUILD_ARCH

WORKDIR /ksa

# 安装必要的依赖和调试工具
RUN apt-get update && apt-get install -y \
    ca-certificates \
    file \
    strace \
    libssl3 \
    libc-bin \
    procps \
    && rm -rf /var/lib/apt/lists/*

# 复制KSA二进制文件
COPY ksa_x64 /ksa/ksa

# 复制配置文件模板
COPY ksa.conf /ksa/ksa.conf.template

RUN chmod +x /ksa/ksa

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 5000/udp

ENTRYPOINT ["/bin/bash", "/run.sh"]
