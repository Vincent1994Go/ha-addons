#!/bin/sh
set -e

CONFIG_PATH=/data/options.json

UID=$(jq --raw-output '.uid // 1000' $CONFIG_PATH)
GID=$(jq --raw-output '.gid // 1000' $CONFIG_PATH)

echo "=== OwnTone Startup Debug Info ==="
echo "UID: $UID, GID: $GID"

# 创建必要的目录
mkdir -p /data/etc /data/media /data/cache

# 设置权限
chown -R $UID:$GID /data
chmod -R 755 /data

echo "Data directories created and permissions set"
ls -la /data/

# 创建符号链接
rm -f /etc/owntone /srv/media /var/cache/owntone
ln -sf /data/etc /etc/owntone
ln -sf /data/media /srv/media
ln -sf /data/cache /var/cache/owntone

# 确保符号链接权限
chown -h $UID:$GID /etc/owntone /srv/media /var/cache/owntone

echo "Symlinks created:"
ls -la /etc/owntone
ls -la /var/cache/owntone
ls -la /srv/media

# 如果配置文件不存在，创建默认配置
if [ ! -f /data/etc/owntone.conf ]; then
    echo "Creating default configuration..."
    cat > /data/etc/owntone.conf << 'EOF'
general {
    db_path = "/var/cache/owntone/database.db"
    loglevel = "info"
    daemon = false
}

library {
    directories = { "/srv/media" }
    filescan_disable = false
    inotify = true
}

mpd {
    port = 6600
}

daap {
    port = 3689
}

webinterface {
    port = 3688
}
EOF
fi

chown $UID:$GID /data/etc/owntone.conf
chmod 644 /data/etc/owntone.conf

echo "==================================="

# 直接运行 OwnTone
echo "Starting OwnTone from /usr/sbin/owntone..."
exec /usr/sbin/owntone -c /etc/owntone/owntone.conf