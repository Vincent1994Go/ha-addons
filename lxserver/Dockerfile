ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH

LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="addon" \
    io.hass.arch="${BUILD_ARCH}"

RUN apk add --no-cache jq tzdata

ENV NODE_ENV=production \
    PORT=9527 \
    DATA_PATH=/data \
    LOG_PATH=/data/logs \
    CONFIG_PATH=/data/config.js \
    TZ=Asia/Shanghai

COPY run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 9527

CMD [ "/run.sh" ]
