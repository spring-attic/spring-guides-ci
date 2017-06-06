FROM openjdk:8-jdk
VOLUME /tmp

ADD source /source
RUN cd /source/complete && ./gradlew build && ./gradlew clean

ENTRYPOINT ["/bin/bash"]
