# KSA (Kanxue Secure Access) 看雪安全接入

KSA 是一个P2P内网穿透工具，允许您安全地访问内网设备。

## 功能特点

- P2P直连，数据传输不经过第三方服务器
- 支持服务器模式和客户端模式
- AES-256-CFB加密
- 支持多平台（x86/x64, ARM, MIPS等）

## 安装

1. 在 Home Assistant 的 Add-on Store 中添加此仓库
2. 找到 "KSA 看雪安全接入" 并安装
3. 配置选项后启动

## 配置说明

### 基础配置

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `mode` | 运行模式: `server` 或 `client` | `server` |
| `host` | KSA服务器地址 | `nat.kanxue.com` |
| `udp_port` | UDP通信端口 | `5000` |
| `cipher` | 加密方式 | `aes_256_cfb` |

### 服务器模式配置

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `nat_nic` | 网卡接口 | `eth0` |
| `nat_tun` | 启用TUN模式 | `false` |
| `dhcp_ip` | DHCP服务器IP | `10.0.0.1` |
| `dhcp_mask` | DHCP子网掩码 | `255.255.255.0` |
| `dhcp_dns` | DNS服务器 | `114.114.114.114` |
| `route` | 路由规则（用逗号分隔） | 空 |

### 客户端模式配置

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `uid` | 用户ID（必填） | 空 |
| `psk` | 预共享密钥（必填） | 空 |
| `tun_name` | TUN设备名称 | `ksa_tun` |
| `tun_ip` | TUN设备IP | `10.0.0.2` |
| `fwd` | 转发模式 | `1` |

## 使用示例

### 服务器模式

```yaml
mode: server
host: nat.kanxue.com
udp_port: 5000
dhcp_ip: "10.0.0.1"
dhcp_mask: "255.255.255.0"
```

### 客户端模式

```yaml
mode: client
uid: "your_uid_here"
psk: "your_password_here"
host: nat.kanxue.com
udp_port: 5000
tun_ip: "10.0.0.2"
```

## 端口说明

- `5000/udp` - KSA UDP通信端口

## 注意事项

1. 客户端模式必须设置 `uid` 和 `psk`
2. 确保防火墙允许UDP端口通信
3. 服务器模式需要 `NET_ADMIN` 权限

## 支持架构

- amd64 (x86_64)

## 更多信息

- 看雪论坛: https://www.kanxue.com
