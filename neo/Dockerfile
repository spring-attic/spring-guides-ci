FROM neo4j
VOLUME /tmp

ENV LANG C.UTF-8

RUN apk update
RUN apk add openjdk8 curl

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["neo4j"]