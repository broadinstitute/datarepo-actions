FROM docker:17.12.0-ce as static-docker-source

RUN apt-get update -qqy && apt-get install -qqy \
        git

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
