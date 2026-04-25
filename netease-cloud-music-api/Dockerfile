FROM homeassistant/amd64-base-python:3.11-alpine3.18

WORKDIR /app

RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    && rm -rf /var/cache/apk/*

RUN git clone https://github.com/neteasecloudmusicapienhanced/api-enhanced.git .

RUN npm install

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3000

CMD [ "/run.sh" ]
