FROM openjdk:8-jdk
VOLUME /tmp

RUN apt-get update
RUN apt-get install gnupg

ADD private.key /private.key
RUN gpg -a --batch --import private.key && rm private.key

ENTRYPOINT ["/bin/bash"]
