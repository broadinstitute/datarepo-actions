FROM google/cloud-sdk:slim

ENV USE_GKE_GCLOUD_AUTH_PLUGIN=true
RUN apt-get install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin=462.0.0-0

ENV HELM_DATA_HOME /usr/local/share/helm

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/v3.5.3/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh \
    && helm plugin install https://github.com/thomastaylor312/helm-namespace

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
