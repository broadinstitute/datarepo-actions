FROM google/cloud-sdk:slim

RUN apt-get install -y jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
