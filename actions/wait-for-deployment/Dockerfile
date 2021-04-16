FROM google/cloud-sdk:slim

RUN apt-get install -y kubectl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
