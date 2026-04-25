# 网易云音乐API Addon

这是一个基于 [NeteaseCloudMusicApiEnhanced](https://github.com/neteasecloudmusicapienhanced/api-enhanced) 项目的 HomeAssistant addon，提供网易云音乐的第三方API服务。

## 功能特性

- 登录/注册/验证码
- 用户信息、歌单、动态、播放记录
- 歌曲、专辑、歌手、MV、歌词、评论、排行榜
- 搜索、推荐、私人 FM、签到、云盘
- 歌曲解锁（解灰）

## 配置说明

### 基本配置

- **cors_allow_origin**: 允许跨域请求的域名，默认为 "*"
- **enable_proxy**: 是否启用反向代理功能，默认为 false
- **proxy_url**: 代理服务地址，仅当 enable_proxy=true 时生效
- **enable_general_unblock**: 是否启用全局解灰（推荐开启），默认为 true
- **enable_flac**: 是否启用无损音质（FLAC），默认为 true
- **select_max_br**: 启用无损音质时，是否选择最高码率音质，默认为 false
- **follow_source_order**: 是否严格按照音源列表顺序进行匹配，默认为 true

## 使用方法

1. 安装 addon 后，点击启动
2. 等待服务启动完成（约1-2分钟）
3. 通过 http://homeassistant:3000 访问API服务

## API文档

详细的API文档请参考项目官方文档：
https://neteasecloudmusicapienhanced.github.io/api-enhanced/

## 注意事项

- 请遵守相关法律法规，尊重网易云音乐的服务条款
- 本项目是第三方API，非官方提供
- 使用时请确保网络连接正常
