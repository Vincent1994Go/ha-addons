#!/bin/sh
set -e

CONFIG_PATH=/data/options.json

UID=$(jq --raw-output '.uid // 1000' $CONFIG_PATH)
GID=$(jq --raw-output '.gid // 1000' $CONFIG_PATH)
LOG_LEVEL=$(jq --raw-output '.log_level // "info"' $CONFIG_PATH)

export UID=$UID
export GID=$GID

mkdir -p /etc/owntone
mkdir -p /srv/media
mkdir -p /var/cache/owntone

chown -R $UID:$GID /etc/owntone
chown -R $UID:$GID /srv/media
chown -R $UID:$GID /var/cache/owntone
chmod -R 755 /etc/owntone
chmod -R 755 /srv/media
chmod -R 755 /var/cache/owntone

if [ ! -f /etc/owntone/owntone.conf ]; then
    echo "创建默认配置文件..."
    cat > /etc/owntone/owntone.conf << 'EOF'
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

chown $UID:$GID /etc/owntone/owntone.conf
chmod 644 /etc/owntone/owntone.conf

echo "=== OwnTone Startup Debug Info ==="
echo "UID: $UID, GID: $GID"
echo "Directory permissions:"
ls -la /etc/owntone/
ls -la /var/cache/owntone/
ls -la /srv/media/
echo "==================================="

exec /entrypoint.sh