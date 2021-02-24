FROM docker:17.12.0-ce as static-docker-source

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
