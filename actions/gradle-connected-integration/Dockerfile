FROM gradle:7.3-jdk17

RUN apt update && apt install -y postgresql-client-12

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
