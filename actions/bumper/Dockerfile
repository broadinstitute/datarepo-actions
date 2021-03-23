FROM alpine/git:1.0.26

RUN apk add jq curl

COPY lib/semver /usr/bin/semver
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
