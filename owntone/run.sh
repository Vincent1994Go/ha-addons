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

# 强制创建新的配置文件，确保没有无效选项
echo "Creating fresh configuration file..."
cat > /data/etc/owntone.conf << 'EOF'
general {
    db_path = "/var/cache/owntone/database.db"
    loglevel = "info"
}

library {
    directories = { "/srv/media" }
    filescan_disable = false
}

mpd {
    port = 6600
}
EOF

chown $UID:$GID /data/etc/owntone.conf
chmod 644 /data/etc/owntone.conf

# 显示配置文件内容
echo "Configuration file content:"
cat /data/etc/owntone.conf

echo "==================================="

# 直接运行 OwnTone
echo "Starting OwnTone from /usr/sbin/owntone..."
exec /usr/sbin/owntone -c /etc/owntone/owntone.conf