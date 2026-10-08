ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_VERSION
ARG BUILD_ARCH

LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="addon" \
    io.hass.arch="${BUILD_ARCH}"

ENV DOCKER_ENV=true \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
