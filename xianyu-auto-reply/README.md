# 闲鱼自动回复 (Home Assistant Add-on)

基于上游项目 [zhinianboke/xianyu-auto-reply](https://github.com/zhinianboke/xianyu-auto-reply) 打包的 Home Assistant Add-on。

单容器内集成 **MySQL + Redis + backend-web + websocket + scheduler + Nginx 前端**，
由 supervisord 统一托管，只对外暴露一个 Web 端口，无需额外部署数据库或缓存服务。

## 功能

- 闲鱼多账号自动回复（关键词 / 默认回复 / AI 回复）
- 自动发货、自动评价
- 商品管理与定时擦亮、自动上架
- WebSocket 实时消息处理与验证码处理
- 前端 Web 管理界面（Nginx 静态托管 + API 反向代理）

## 安装

1. 在 Home Assistant 中打开 `设置` -> `加载项` -> `加载项商店`。
2. 右上角 `⋮` -> `软件仓库`，添加本仓库地址：
   `https://github.com/Vincent1994Go/ha-addons`
3. 刷新后找到 **闲鱼自动回复**，点击安装。
4. 启动加载项，点击「打开 Web UI」或访问 `http://<HA地址>:9000/`。

## 配置项

| 配置项 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `timezone` | str | `Asia/Shanghai` | 容器时区 |
| `log_level` | list | `INFO` | 日志级别：`DEBUG` / `INFO` / `WARNING` / `ERROR` |
| `mysql_password` | password | `xianyu@2026` | 内置 MySQL 的 `xianyu` 用户密码 |
| `redis_password` | password | `xianyu@2026` | 内置 Redis 密码 |
| `auto_start_websocket` | bool | `true` | 启动时自动拉起 WebSocket 连接 |
| `auto_start_crawl_jobs` | bool | `true` | 启动时自动恢复定时任务 |
| `max_captcha_concurrent` | int(1,20) | `3` | 验证码并发处理上限 |
| `browser_headless` | bool | `true` | 浏览器无头模式 |

> 修改 `mysql_password` 后重启加载项会自动重设数据库用户密码；
> 修改 `redis_password` 后重启生效。两项均为内部使用，无需与外部服务保持一致。

## 端口

| 端口 | 说明 |
| --- | --- |
| `9000/tcp` | Web 管理界面（唯一对外端口） |

内部服务仅监听 `127.0.0.1`：backend-web `8089`、websocket `8090`、scheduler `8091`、
MySQL `3306`、Redis `6379`，均不对外暴露。

## 数据持久化

所有数据保存在加载项数据目录 `/data/xianyu` 下，随加载项备份一起保留：

| 路径 | 内容 |
| --- | --- |
| `/data/xianyu/mysql` | MySQL 数据目录 |
| `/data/xianyu/redis` | Redis AOF 持久化 |
| `/data/xianyu/static` | 上传的图片等静态资源 |
| `/data/xianyu/backups` | 应用内备份文件 |
| `/data/xianyu/browser_data` | 浏览器（Playwright/Chromium）会话数据 |

## 资源要求

- 架构：**仅 amd64**
- 建议：**2 核 CPU / 4 GB 内存以上**（首次启动需初始化 MySQL，耗时较长属正常现象）
- 磁盘：建议预留 5 GB 以上（镜像本身较大，含 Chromium 运行时）

## 说明

- 本加载项直接复用上游发布的预构建镜像作为基础镜像组装，不在本机编译上游源码，
  因此构建速度快，但需要构建时能访问 `registry.cn-shanghai.aliyuncs.com`。
- 首次启动会初始化 MySQL 数据目录并创建数据库 `xianyu_data` 与用户 `xianyu`；
  后续启动检测到已有数据会自动跳过初始化。
- 上游源码与文档：<https://github.com/zhinianboke/xianyu-auto-reply>
