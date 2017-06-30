FROM rabbitmq:management-alpine

ENV LANG C.UTF-8

RUN apk add --no-cache openjdk8

EXPOSE 5672 15672

CMD ["rabbitmq-server"]