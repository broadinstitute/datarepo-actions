# Container image that runs your code
FROM alpine/k8s:1.14.9

RUN apk --update add git bash

ENV HELM_PLUGIN_DIR ./root/.local/share/helm/plugins/helm-namespace
RUN helm plugin install https://github.com/thomastaylor312/helm-namespace

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
