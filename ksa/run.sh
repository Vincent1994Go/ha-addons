#!/bin/bash

# 获取配置参数
MODE=${MODE:-"server"}
KSA_UID=${KSA_UID:-""}
PASSWORD=${PASSWORD:-"993745"}
HOST=${HOST:-"nat.kanxue.com"}
UDP_PORT=${UDP_PORT:-5000}
DHCP_IP=${DHCP_IP:-"10.0.0.1"}
DHCP_MASK=${DHCP_MASK:-"255.255.255.0"}
DHCP_DNS=${DHCP_DNS:-"114.114.114.114"}
NAT_NIC=${NAT_NIC:-"eth0"}
NAT_TUN=${NAT_TUN:-0}
TUN_NAME=${TUN_NAME:-"ksa_tun"}
TUN_IP=${TUN_IP:-"10.0.0.2"}
FWD=${FWD:-1}
CIPHER=${CIPHER:-"aes_256_cfb"}
ROUTE=${ROUTE:-""}

DATA_DIR=/data
CONFIG_FILE=$DATA_DIR/ksa.conf

mkdir -p $DATA_DIR

# 检查是否已有KSA进程在运行
if pgrep -x "ksa" > /dev/null 2>&1; then
    pkill -x "ksa"
    sleep 2
fi

# 生成配置文件
cat > $CONFIG_FILE << EOF
[log]=$DATA_DIR/ksa.log
[host]=$HOST
[udp]=$UDP_PORT
EOF

if [ "$MODE" = "server" ]; then
    cat >> $CONFIG_FILE << EOF
[nat_nic]=$NAT_NIC
[nat_tun]=$NAT_TUN
[dhcp_ip]=$DHCP_IP
[dhcp_mask]=$DHCP_MASK
[dhcp_dns]=$DHCP_DNS
[cipher]=$CIPHER
EOF

    if [ -n "$ROUTE" ]; then
        echo "[route]=" >> $CONFIG_FILE
        echo "$ROUTE" | tr ',' '\n' >> $CONFIG_FILE
    fi
else
    if [ -z "$KSA_UID" ]; then
        exit 1
    fi
    
    cat >> $CONFIG_FILE << EOF
[uid]=$KSA_UID
[psk]=$PASSWORD
[tun_name]=$TUN_NAME
[tun_ip]=$TUN_IP
[fwd]=$FWD
[cipher]=$CIPHER
EOF
fi

# 创建TUN设备
if [ ! -d /dev/net ]; then
    mkdir -p /dev/net
fi

if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

cd /ksa

# 启动KSA
/ksa/ksa --psk "$PASSWORD" --cfg "$CONFIG_FILE" &
KSA_PID=$!

# 等待KSA启动并获取ID
sleep 3

if [ -f "$DATA_DIR/ksa.log" ]; then
    KSA_ID=$(grep "KSA server start" $DATA_DIR/ksa.log 2>/dev/null | tail -1 | grep -oE "KSA server [0-9]+" | awk '{print $3}')
    if [ -n "$KSA_ID" ]; then
        echo "KSA ID: $KSA_ID"
        echo "密码: $PASSWORD"
    fi
fi

# 监控KSA进程
while true; do
    if ! ps -p $KSA_PID > /dev/null 2>&1; then
        /ksa/ksa --psk "$PASSWORD" --cfg "$CONFIG_FILE" &
        KSA_PID=$!
    fi
    sleep 30
done
