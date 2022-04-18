FROM node:16-alpine

RUN apk --no-cache add curl

WORKDIR /app

COPY ./api.sh /app/api.sh

ENTRYPOINT ["/app/api.sh"]