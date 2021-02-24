FROM docker:17.12.0-ce as static-docker-source

COPY --from=static-docker-source /usr/local/bin/docker /usr/local/bin/docker
RUN apt-get update -qqy && \
    apt-get install -qqy \
      git

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
