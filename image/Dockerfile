FROM openjdk:8-jdk-alpine
VOLUME /tmp

RUN apk add --no-cache bash gnupg

ADD private.key /private.key
RUN gpg -a --batch --import private.key && rm private.key

ENTRYPOINT ["/bin/bash"]
