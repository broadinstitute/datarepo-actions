FROM gradle:6.8.3-jdk11

RUN apt update && apt install -y postgresql-client-12

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
