FROM google/cloud-sdk:slim

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y wget
RUN wget https://dl.k8s.io/release/v1.25.4/bin/linux/amd64/kubectl 
RUN dpkg -i kubectl_1.25.4-00_amd64.deb
RUN apt-get update

# RUN apt-get install -y \
#  google-cloud-sdk-gke-gcloud-auth-plugin

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
