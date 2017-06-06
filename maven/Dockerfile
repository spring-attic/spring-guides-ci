FROM openjdk:8-jdk-alpine
VOLUME /tmp

RUN apk add --update gnupg

ADD private.key /private.key
RUN gpg -a --batch --import private.key && rm private.key

ADD source /source
RUN cd /source/complete && ./mvnw install && ./mvnw clean

ENTRYPOINT ["/bin/sh"]
