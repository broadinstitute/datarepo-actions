FROM google/cloud-sdk:slim

RUN apt-get install -y kubectl

ENV HELM_DATA_HOME /usr/local/share/helm

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/v3.5.3/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh \
    && helm plugin install https://github.com/thomastaylor312/helm-namespace \
    && helm repo add datarepo-helm https://broadinstitute.github.io/datarepo-helm \
    && helm repo update

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
