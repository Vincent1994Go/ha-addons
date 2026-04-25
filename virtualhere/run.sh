#!/bin/bash

echo "Starting VirtualHere USB Server..."

LICENSE_KEY=${LICENSE_KEY:-""}
SERVER_NAME=${SERVER_NAME:-"VirtualHere Server"}
SERIAL_NUMBER=${SERIAL_NUMBER:-""}
DATA_DIR=/data

mkdir -p $DATA_DIR

if [ -n "$LICENSE_KEY" ]; then
    echo "License key configured"
fi

if [ -n "$SERIAL_NUMBER" ]; then
    echo "Serial Number: $SERIAL_NUMBER"
fi

echo "Server Name: $SERVER_NAME"
echo "Data Directory: $DATA_DIR"

CONFIG_FILE=$DATA_DIR/config.ini

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating initial config.ini..."
    cat > $CONFIG_FILE << EOF
[General]
AutoFind=1
ServerName=$SERVER_NAME
EOF
    
    # 如果提供了序列号，添加到配置
    if [ -n "$SERIAL_NUMBER" ]; then
        echo "SerialNumber=$SERIAL_NUMBER" >> $CONFIG_FILE
    fi
fi

# 更新服务器名称
sed -i "s/ServerName=.*/ServerName=$SERVER_NAME/" $CONFIG_FILE 2>/dev/null || true

# 如果提供了序列号，更新或添加序列号
if [ -n "$SERIAL_NUMBER" ]; then
    if grep -q "SerialNumber=" $CONFIG_FILE 2>/dev/null; then
        sed -i "s/SerialNumber=.*/SerialNumber=$SERIAL_NUMBER/" $CONFIG_FILE 2>/dev/null || true
    else
        echo "SerialNumber=$SERIAL_NUMBER" >> $CONFIG_FILE
    fi
fi

echo "Config file content:"
cat $CONFIG_FILE

cd /vhserver

echo "Starting VirtualHere Server..."
exec /vhserver/vhusbd -c $CONFIG_FILE
