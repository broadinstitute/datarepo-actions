FROM google/cloud-sdk:slim

RUN apt-get update -qqy && apt-get install -qqy \
    kubectl \
    jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
