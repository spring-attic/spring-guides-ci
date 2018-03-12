FROM openjdk:8-jdk
VOLUME /tmp

RUN apt-get install gnupg
#RUN apk add --no-cache bash gnupg

#ADD private.key /private.key
#RUN gpg -a --batch --import private.key && rm private.key

#ADD source /source
#RUN cd /source/complete && ./mvnw install -Dmaven.repo.local=../.m2 && rm -rf target
#RUN cd /source/complete && ./gradlew build -g ../.gradle && rm -rf build

ENTRYPOINT ["/bin/sh"]
