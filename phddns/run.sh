echo "Starting phddns service..."

# 启用并启动phddns服务
phddns enable
phddns start

# 等待服务启动
sleep 10

# 显示状态信息
phddns status

# 保持容器运行
while true; do
    sleep 60
    phddns status
done
