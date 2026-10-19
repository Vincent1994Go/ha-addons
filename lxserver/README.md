# LX Music Sync Server Add-on

基于 [XCQ0607/lxserver](https://github.com/XCQ0607/lxserver)（LX Music 数据同步服务端 · 增强版）的 Home Assistant 插件。

插件直接复用上游官方多架构镜像，无需在本机编译，启动速度快。

## 功能特性

- **LX Music 数据同步**：歌单、设置、自定义源等多端同步，支持用户路径模式与根路径模式
- **Web 音乐播放器**：内置网页播放器，支持多源聚合搜索、多平台歌单、本地音乐库、歌词卡片、主题切换
- **管理后台**：仪表盘、用户管理、数据查看、快照备份/回滚、日志浏览
- **Subsonic 协议**：可被音流、Feishin、Symfonium 等客户端连接
- **WebDAV 备份**：支持定时增量同步与全量备份到坚果云 / Nextcloud / Alist 等

## 访问方式

默认端口 `9527`（插件页面的「打开 Web UI」按钮可直接跳转）：

| 功能 | 地址 |
| --- | --- |
| Web 播放器 | `http://<HA-IP>:9527/` |
| 管理后台 | `http://<HA-IP>:9527/admin` |
| LX Music 同步（用户路径模式） | `http://<HA-IP>:9527/<用户名>` |
| Subsonic 服务 | `http://<HA-IP>:9527/rest` |

- 管理后台默认密码：`123456`，**安装后请立即在插件配置中修改**
- 首次使用请到「用户管理」中为 LX Music 客户端创建同步账号

## 配置说明

插件选项会以环境变量形式注入，**优先级高于 `config.js` 与管理后台中的设置**，即：需要长期生效的配置请写在插件选项中，否则重启后会被选项值覆盖。若想彻底交给管理后台管理，请保持选项为默认值或留空。

### 基本

| 选项 | 说明 | 默认值 |
| --- | --- | --- |
| `admin_password` | 管理后台密码（同时用于播放器内的管理员登录） | `123456` |
| `server_name` | 同步服务名称（客户端连接列表与后台标题） | `lxserver` |
| `player_name` | Web 播放器名称 | `LX Music Web` |
| `enable_webplayer_auth` | 是否启用播放器访问密码 | `false` |
| `webplayer_password` | 播放器访问密码 | `123456` |
| `admin_path` | 管理后台访问路径 | `/admin` |
| `player_path` | Web 播放器访问路径 | `/` |
| `max_snapshot_num` | 每位用户保留的快照数量（1-100） | `10` |
| `list_add_music_location_type` | 添加歌曲到列表时的位置：`top` 顶部 / `bottom` 底部（播放器与 Subsonic 共用） | `top` |
| `disable_telemetry` | 禁用匿名统计、更新提醒与公告 | `false` |
| `enable_debug` | 开启调试日志 | `false` |

> 修改 `admin_path` 或 `player_path` 后，「打开 Web UI」按钮仍指向根路径，需要手动访问新地址。

### 缓存与配置文件备份

| 选项 | 说明 | 默认值 |
| --- | --- | --- |
| `enable_cache_size_limit` | 开启缓存空间限制，超出容量后按 LRU 自动清理 | `false` |
| `cache_size_limit` | 缓存上限（MB），仅在开启限制时生效 | `2000` |
| `config_backup_enable` | 每日生成一份 `config.js` 本地副本并自动清理过期备份 | `true` |
| `config_backup_retention_days` | 配置文件备份保留天数（1-365） | `7` |

### 同步模式

| 选项 | 说明 | 默认值 |
| --- | --- | --- |
| `enable_user_path` | 启用用户路径模式：连接地址为 `http://IP:9527/<用户名>`，允许多用户使用相同密码 | `true` |
| `enable_user_root` | 启用根路径模式：连接地址为 `http://IP:9527`，要求所有用户密码唯一 | `false` |

### 用户

`users` 用于快速创建同步用户，每项包含 `username`（仅支持字母、数字、下划线）与 `password`。
创建后仍可在管理后台「用户管理」中增删改查。

> 用户名会作为环境变量 `LX_USER_<用户名>` 注入，因此不支持中文等非 ASCII 字符；这类用户请直接在管理后台创建。

### 音乐目录

`enable_custom_music_dir`：开启后可在管理后台为单个用户设置自定义歌曲目录，例如 `/media/lxmusic`（插件已映射 `media` 与 `share` 目录）。
关闭时歌曲默认下载/缓存到 `/data/<用户名>/music`，随插件一起持久化。

### Subsonic

| 选项 | 说明 | 默认值 |
| --- | --- | --- |
| `subsonic_enable` | 启用 Subsonic 协议 | `true` |
| `subsonic_path` | Subsonic 接口路径 | `/rest` |
| `subsonic_online_search` | 允许 Subsonic 客户端在线全网搜索 | `true` |
| `subsonic_online_search_mode` | 在线搜索模式：`fallback` 无结果时回退 / `merge` 合并本地与在线 / `local_only` 仅本地 | `fallback` |
| `subsonic_online_search_sources` | 在线搜索默认平台，英文逗号分隔（`wy`/`tx`/`kw`/`kg`/`mg`） | `wy,tx,kw,kg,mg` |
| `subsonic_quality_enabled` | 按优先级主动选择最优可用音质 | `true` |
| `subsonic_quality_priority` | 音质优先级，从高到低，英文逗号分隔 | `flac,320k,128k` |
| `subsonic_cache_on_play` | 播放时把歌曲写入服务器缓存目录 | `false` |
| `subsonic_play_cache_first` | 播放时优先直接串流本地缓存/下载文件 | `true` |

### WebDAV 备份

| 选项 | 说明 | 默认值 |
| --- | --- | --- |
| `webdav_enable` | 启用 WebDAV 同步与备份 | `false` |
| `webdav_url` | WebDAV 服务地址 | - |
| `webdav_username` | WebDAV 用户名 | - |
| `webdav_password` | WebDAV 密码 | - |
| `webdav_sync_path` | 增量同步远端路径 | `/lx-sync` |
| `webdav_backup_path` | 全量备份远端路径 | `/lx-sync-backups` |
| `sync_interval` | 同步检测间隔（分钟，1-1440） | `60` |
| `backup_interval` | 全量备份间隔（小时，1-168） | `24` |
| `webdav_exclude_cache` | 同步与备份时排除各用户缓存目录 | `false` |
| `webdav_exclude_music` | 同步与备份时排除各用户音乐目录 | `false` |

### 出站代理

| 选项 | 说明 | 默认值 |
| --- | --- | --- |
| `proxy_all_enabled` | 为所有外发请求启用代理（主要用于离线音源的播放链接获取） | `false` |
| `proxy_all_address` | 代理地址，支持 `http://` 与 `socks5://`，例如 `http://192.168.1.2:7890` | - |
| `proxy_header` | 反向代理传入真实 IP 的请求头，如 `x-real-ip`。设置后会自动开启代理请求模式，留空则不启用 | - |

上游还支持为「音乐平台 / 自定义音源 / 应用功能」分别设置代理（`proxy.music.*`、`proxy.customSource.*`、`proxy.app.*`）。这类细分配置无法用单个环境变量表达，需要直接编辑 `/data/config.js` 后重启插件。

## 数据存储

- 配置（`/data/config.js`）、用户数据、快照、缓存、下载的歌曲均保存在插件的 `/data` 目录，升级或重启不丢失
- `/media`、`/share` 以读写方式映射，可作为自定义歌曲目录
- 插件备份类型为 `cold`，备份时会包含 `/data`（若下载了大量歌曲，备份体积会较大）

## 端口

- `9527/tcp`：Web 播放器、管理后台、LX Music 同步、Subsonic 接口共用此端口
- 可在插件「网络」设置中修改宿主机端口，容器内端口固定为 `9527`

## 注意事项

- 本插件仅为上游项目的封装，未修改任何业务代码，功能与上游 Docker 镜像完全一致
- 上游项目基于 Apache-2.0 协议发布，使用前请阅读其补充协议与免责声明
