# Container image that runs your code
FROM alpine/k8s:1.14.9

RUN apk --update add git bash

RUN helm plugin install https://github.com/thomastaylor312/helm-namespace

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
