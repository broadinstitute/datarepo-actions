FROM google/cloud-sdk:slim

ENV USE_GKE_GCLOUD_AUTH_PLUGIN=true

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
