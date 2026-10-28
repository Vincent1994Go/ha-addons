## 2.1.4

- 升级至上游 `xcq0607/lxserver:v2.1.4`
- 上游新增 Subsonic 本地歌曲/自定义目录歌单、用户禁用与在线状态指示、播放页动态特效、本地音乐智能检测、桌面端侧边栏折叠、VueFinder 文件管理器等功能
- Subsonic 配置独立管理页；新增独立端口监听（上游默认关闭）
- `subsonic_play_cache_first` 默认值跟随上游调整为 `false`
- 上游删除废弃配置项 `subsonic.clientCapMode`、`transcode.onQualityMiss`

## 2.1.3

- 初始版本，封装上游 `xcq0607/lxserver:v2.1.3` 多架构镜像（`amd64` / `aarch64` / `armv7`）
- 支持 LX Music 数据同步、Web 播放器、管理后台、Subsonic 协议与 WebDAV 备份
- 配置、日志、缓存与用户数据统一持久化到 `/data`，升级与重启不丢失
- 映射 `media`、`share` 目录，可作为自定义歌曲目录
- 常用配置项可在插件页面设置：管理密码、同步模式、用户列表、快照数量、缓存限制、配置文件备份、Subsonic 参数、WebDAV 同步/备份路径与间隔、出站代理
