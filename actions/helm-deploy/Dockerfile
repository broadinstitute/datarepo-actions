FROM google/cloud-sdk:slim

RUN apt-get install -y kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/v3.5.3/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]