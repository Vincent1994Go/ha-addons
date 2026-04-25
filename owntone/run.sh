#!/bin/sh
set -e

CONFIG_PATH=/data/options.json

UID=$(jq --raw-output '.uid // 1000' $CONFIG_PATH)
GID=$(jq --raw-output '.gid // 1000' $CONFIG_PATH)
LOG_LEVEL=$(jq --raw-output '.log_level // "info"' $CONFIG_PATH)

export UID=$UID
export GID=$GID

mkdir -p /data/etc /data/media /data/cache
chown -R $UID:$GID /data
chmod -R 755 /data

mkdir -p /etc/owntone /srv/media /var/cache/owntone

ln -sf /data/etc /etc/owntone
ln -sf /data/media /srv/media
ln -sf /data/cache /var/cache/owntone

chown -h $UID:$GID /etc/owntone /srv/media /var/cache/owntone

if [ ! -f /data/etc/owntone.conf ]; then
    echo "创建默认配置文件..."
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

audio {
}

airplay {
}

chromecast {
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

echo "=== OwnTone Startup Debug Info ==="
echo "UID: $UID, GID: $GID"
echo "Directory permissions:"
ls -la /data/
ls -la /data/cache/
ls -la /var/cache/owntone
ls -la /etc/owntone/
echo "==================================="

# 直接运行 OwnTone
exec su-exec $UID:$GID /usr/bin/owntone