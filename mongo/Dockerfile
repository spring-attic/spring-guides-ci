FROM openjdk:8-jdk
VOLUME /tmp
VOLUME /data/db

ENV LANG C.UTF-8

RUN apt-get update
RUN apt-get install -y mongodb

CMD ["mongod"]