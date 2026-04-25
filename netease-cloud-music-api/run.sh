#!/bin/sh

export CORS_ALLOW_ORIGIN=${CORS_ALLOW_ORIGIN:-"*"}
export ENABLE_PROXY=${ENABLE_PROXY:-"false"}
export PROXY_URL=${PROXY_URL:-"https://your-proxy-url.com/?proxy="}
export ENABLE_GENERAL_UNBLOCK=${ENABLE_GENERAL_UNBLOCK:-"true"}
export ENABLE_FLAC=${ENABLE_FLAC:-"true"}
export SELECT_MAX_BR=${SELECT_MAX_BR:-"false"}
export FOLLOW_SOURCE_ORDER=${FOLLOW_SOURCE_ORDER:-"true"}

node app.js
