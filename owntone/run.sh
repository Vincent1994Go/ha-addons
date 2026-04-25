#!/bin/sh
set -e

# 从配置中读取参数
CONFIG_PATH=/data/options.json

UID=$(jq --raw-output '.uid // 1000' $CONFIG_PATH)
GID=$(jq --raw-output '.gid // 1000' $CONFIG_PATH)
LOG_LEVEL=$(jq --raw-output '.log_level // "info"' $CONFIG_PATH)

# 设置环境变量供官方镜像使用
export UID=$UID
export GID=$GID

# 创建必要的目录结构
# 这些目录用于持久化存储
mkdir -p /data/owntone/etc
mkdir -p /data/owntone/media
mkdir -p /data/owntone/cache

# 设置权限
chown -R $UID:$GID /data/owntone
chmod -R 755 /data/owntone

# 创建符号链接到 owntone 期望的路径
# 官方镜像使用以下路径：
# - /etc/owntone (配置)
# - /srv/media (媒体文件)
# - /var/cache/owntone (缓存和数据库)

# 备份原始目录（如果存在且不是符号链接）
if [ -d /etc/owntone ] && [ ! -L /etc/owntone ]; then
    mv /etc/owntone /etc/owntone.bak
fi
if [ -d /var/cache/owntone ] && [ ! -L /var/cache/owntone ]; then
    mv /var/cache/owntone /var/cache/owntone.bak
fi
if [ -d /srv/media ] && [ ! -L /srv/media ]; then
    mv /srv/media /srv/media.bak
fi

# 强制重新创建符号链接
rm -f /etc/owntone /var/cache/owntone /srv/media

ln -sf /data/owntone/etc /etc/owntone
ln -sf /data/owntone/cache /var/cache/owntone
ln -sf /data/owntone/media /srv/media

# 确保符号链接本身有正确的权限
chown -h $UID:$GID /etc/owntone
chown -h $UID:$GID /var/cache/owntone
chown -h $UID:$GID /srv/media

# 再次确保目标目录权限正确
chown -R $UID:$GID /data/owntone
chmod -R 755 /data/owntone

# 如果配置目录为空，创建默认配置
if [ ! -f /data/owntone/etc/owntone.conf ]; then
    echo "创建默认配置文件..."
    cat > /data/owntone/etc/owntone.conf << 'EOF'
# OwnTone 配置文件
general {
    # 数据库文件路径
    db_path = "/var/cache/owntone/database.db"

    # 调试日志级别: fatal, log, warning, info, debug, spam
    loglevel = "info"

    # 管理员密码 (Web界面)
    # admin_password = ""

    # 是否作为后台服务运行
    daemon = false

    # Web界面根目录
    # websockets = true
}

library {
    # 音乐文件目录
    directories = { "/srv/media" }

    # 扫描间隔 (秒), 0 表示禁用自动扫描
    filescan_disable = false

    # 是否监视文件变化
    inotify = true
}

# 音频输出配置
audio {
    # 默认音量 (0-100)
    # volume = 100

    # 音频输出设备
    # type = "alsa"
}

# AirPlay 配置
airplay {
    # 共享 AirPlay 设备
    # share_playing_source = true
}

# Chromecast 配置
chromecast {
    # 启用 Chromecast 支持
    # enabled = true
}

# MPD 配置
mpd {
    # 启用 MPD 协议支持
    port = 6600
}

# 远程控制配置 (DAAP)
daap {
    # 端口
    port = 3689
}

# Web界面配置
webinterface {
    # 端口
    port = 3688

    # 文档根目录
    # document_root = "/usr/share/owntone/htdocs"
}
EOF
fi

# 设置配置文件权限
chown $UID:$GID /data/owntone/etc/owntone.conf
chmod 644 /data/owntone/etc/owntone.conf

# 调试信息
echo "=== OwnTone Startup Debug Info ==="
echo "UID: $UID, GID: $GID"
echo "Symlinks:"
ls -la /etc/owntone
ls -la /var/cache/owntone
ls -la /srv/media
echo "Data directories:"
ls -la /data/owntone/
ls -la /data/owntone/cache/
echo "==================================="

# 启动 OwnTone 服务
# 使用官方镜像的启动方式
exec /entrypoint.sh