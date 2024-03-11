FROM google/cloud-sdk:slim

ENV USE_GKE_GCLOUD_AUTH_PLUGIN=true

RUN apt-get install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
