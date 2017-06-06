FROM rabbitmq:management

ENV LANG C.UTF-8

RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
RUN apt-get update
RUN apt-get install -y -t jessie-backports openjdk-8-jdk ca-certificates-java

CMD ["/bin/sh"]