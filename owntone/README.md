# OwnTone Home Assistant Add-on

这是一个将 [OwnTone](https://github.com/owntone/owntone-server) 媒体服务器打包为 Home Assistant Add-on 的项目。

## 功能特性

- **媒体服务器**: 支持多种音频格式，包括 MP3, FLAC, AAC, ALAC 等
- **AirPlay 支持**: 可以将音频流式传输到 AirPlay 设备
- **Chromecast 支持**: 支持 Chromecast 设备
- **MPD 协议**: 兼容 MPD (Music Player Daemon) 客户端
- **Web 界面**: 内置 Web 界面用于管理和播放音乐
- **DAAP 协议**: 支持 iTunes 远程控制

## 安装

1. 在 Home Assistant 中，进入 **设置** → **加载项** → **加载项商店**
2. 点击右上角菜单，选择 **仓库**
3. 添加此仓库地址: `https://github.com/Vincent1994Go/ha-addons`
4. 找到 "OwnTone" 加载项并安装

## 配置

### 基本配置

```yaml
uid: 1000                    # 运行 OwnTone 的用户 ID
gid: 1000                    # 运行 OwnTone 的组 ID
log_level: info              # 日志级别: debug, info, warning, error
```

### 目录结构

加载项使用以下目录存储数据：

- **配置目录**: `/data/owntone/etc/` - 包含 owntone.conf 配置文件
- **媒体目录**: `/data/owntone/media/` - 存放音乐文件
- **缓存目录**: `/data/owntone/cache/` - 数据库和缓存文件

### 添加音乐

将你的音乐文件放入 `/share/owntone/media/` 目录，OwnTone 会自动扫描并索引这些文件。

## 访问

安装并启动后，可以通过以下方式访问：

- **Web 界面**: `http://<你的HomeAssistantIP>:3688`
- **MPD 端口**: 6600
- **DAAP 端口**: 3689

## 网络模式

此加载项使用 **Host 网络模式**，以便 OwnTone 能够正确发现和控制网络中的音频设备（如 AirPlay 和 Chromecast 设备）。

## 注意事项

1. 首次启动时，加载项会创建一个默认的配置文件
2. 请将音乐文件放入 `/share/owntone/media/` 目录
3. 如果需要修改配置，可以编辑 `/share/owntone/etc/owntone.conf` 文件
4. 确保缓存目录有写入权限

## 相关链接

- [OwnTone 官方文档](https://owntone.github.io/owntone-server/)
- [OwnTone GitHub](https://github.com/owntone/owntone-server)
- [OwnTone Container](https://github.com/owntone/owntone-container)

## 许可证

此加载项遵循与 OwnTone 相同的许可证。
