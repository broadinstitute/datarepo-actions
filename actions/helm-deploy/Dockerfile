# Container image that runs your code
FROM alpine/helm:3.2.1

ARG KUBECTL_VERSION=1.18.12

RUN apk add --update --no-cache curl bash git && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
