FROM google/cloud-sdk:slim

RUN apt-get install -y kubectl \
 google-cloud-sdk-gke-gcloud-auth-plugin

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
