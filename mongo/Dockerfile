FROM openjdk:8-jdk-alpine
VOLUME /tmp
VOLUME /data/db

ENV LANG C.UTF-8

RUN apk add --no-cache bash mongodb

EXPOSE 27017

CMD ["mongod"]