FROM alpine/git:1.0.26

RUN apk add yq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
