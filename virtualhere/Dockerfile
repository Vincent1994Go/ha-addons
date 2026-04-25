FROM alpine:3.19

ARG BUILD_ARCH

RUN apk add --no-cache wget ca-certificates

WORKDIR /vhserver

RUN if [ "$BUILD_ARCH" = "amd64" ]; then \
        wget -q "https://www.virtualhere.com/sites/default/files/usbserver/vhusbdx86_64" -O vhusbd; \
    elif [ "$BUILD_ARCH" = "i386" ]; then \
        wget -q "https://www.virtualhere.com/sites/default/files/usbserver/vhusbdi386" -O vhusbd; \
    elif [ "$BUILD_ARCH" = "armhf" ]; then \
        wget -q "https://www.virtualhere.com/sites/default/files/usbserver/vhusbdarm" -O vhusbd; \
    elif [ "$BUILD_ARCH" = "aarch64" ]; then \
        wget -q "https://www.virtualhere.com/sites/default/files/usbserver/vhusbdarm64" -O vhusbd; \
    else \
        echo "Unsupported architecture: $BUILD_ARCH"; \
        exit 1; \
    fi

RUN chmod +x vhusbd

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 7575

ENTRYPOINT ["/bin/sh", "/run.sh"]
