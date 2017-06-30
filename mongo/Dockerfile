FROM openjdk:8-jdk-alpine
VOLUME /tmp
VOLUME /data/db

ENV LANG C.UTF-8

RUN apk add --no-cache bash mongodb

CMD ["mongod"]