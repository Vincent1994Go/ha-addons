#!/bin/sh
set -e

CONFIG_PATH=/data/options.json

UID=$(jq --raw-output '.uid // 1000' $CONFIG_PATH)
GID=$(jq --raw-output '.gid // 1000' $CONFIG_PATH)

echo "=== OwnTone Startup Debug Info ==="
echo "UID: $UID, GID: $GID"

# 创建必要的目录
mkdir -p /data/etc /data/media /data/cache

# 设置权限 - 确保所有者和组都正确
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

# 检查数据库目录权限
echo "Checking database directory permissions..."
ls -la /var/cache/owntone/

# 如果数据库文件存在，确保权限正确
if [ -f /var/cache/owntone/database.db ]; then
    echo "Database file exists, fixing permissions..."
    chown $UID:$GID /var/cache/owntone/database.db
    chmod 644 /var/cache/owntone/database.db
else
    echo "Database file does not exist yet, will be created on first run"
fi

# 尝试启动 OwnTone
echo "Starting OwnTone..."

# 方法：直接运行，不使用 OpenRC 服务
echo "Starting OwnTone directly..."
/usr/sbin/owntone -c /etc/owntone/owntone.conf 2>&1 &

# 等待几秒钟让进程启动
sleep 5

# 检查进程状态
echo "Checking OwnTone process status..."
ps aux | grep owntone || echo "No owntone process found"

# 检查数据库文件是否被创建
echo "Checking if database was created..."
ls -la /var/cache/owntone/

# 等待进程结束
wait