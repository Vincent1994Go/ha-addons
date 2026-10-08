# 闲鱼超级管家 Add-on

面向闲鱼卖家的账号、商品、订单、消息、自动回复与自动发货一体化管理系统，
移植自 [23Star/xianyu-super-butler](https://github.com/23Star/xianyu-super-butler)。

本 add-on 直接基于上游预构建镜像 `ghcr.io/23star/xianyu-super-butler:latest`，
不在 Home Assistant 主机上编译，安装快、对低配设备友好（amd64 / aarch64）。

## 功能特性

- **多账号管理** — 扫码 / 密码 / Cookie 登录，一个后台管完所有账号
- **自动发货** — 卡密自动发出，支持多规格、多数量，发货前风险拦截
- **自动回复** — 关键词精确命中 + AI 议价，可设最低价与议价轮数
- **买家互动** — 确认收货后自动评价、自动求小红花、自动致谢
- **商品自动化** — 商品同步、素材库、定时擦亮、自动上下架
- **经营看板** — 成交额、到账、退款、订单和库存一屏掌握

## 配置说明

- **admin_username** / **admin_password**：管理员账号密码。
  仅在首次创建数据库时生效；数据库已存在时改这里不会改密码，请在后台「设置 → 修改登录密码」修改。
- **timezone**：时区，默认 `Asia/Shanghai`。
- **log_level**：日志级别，可选 `DEBUG` / `INFO` / `WARNING` / `ERROR`。
- **auto_reply_enabled**：是否启用自动回复。
- **auto_delivery_enabled**：是否启用自动发货。
- **ai_reply_enabled**：是否启用 AI 回复（需在后台配置大模型）。
- **multiuser_enabled**：是否启用多用户模式。
- **user_registration_enabled**：是否开放注册。
- **email_verification_enabled**：注册是否启用邮箱验证。

## 使用方法

1. 安装 add-on 后点击「启动」。
2. 打开「闲鱼超级管家」面板，或访问 `http://<你的HA地址>:8080/`。
3. 使用配置的管理员账号登录（默认 `admin` / `admin123`），登录后请立即修改密码。
4. 在「账号」页扫码或登录闲鱼账号，随后即可配置商品、卡密与自动回复规则。

## 数据持久化

以下数据保存在 add-on 的 `/data/xianyu` 目录中，升级或重装容器不会丢失：

- `data/` — SQLite 数据库
- `logs/` — 运行日志
- `backups/` — 备份文件
- `uploads/` — 商品图片等上传素材
- `global_config.yml` — 全局配置

## 端口

- `8080/tcp` — Web 管理界面与 API 文档（`/docs`），健康检查 `/health`。

## 注意事项

- 本项目内置反检测浏览器（Patchright）、验证码处理与通知组件，
  **请勿部署到共享托管平台**，推荐本地设备、自有 VPS 或国内服务器。
- 海外出口 IP 会显著增加闲鱼风控触发概率。
- 首次启动需初始化数据库，请耐心等待约 1-2 分钟。
- 本项目仅供学习、研究和合法自动化使用，请遵守相关法律法规及平台规则。

## 上游项目

- 项目地址：https://github.com/23Star/xianyu-super-butler
- 许可协议：AGPL-3.0
