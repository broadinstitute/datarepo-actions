#!/bin/bash

function gradleinttest {
  if [[ -f "env_var_tag" ]]; then
    gcloud container clusters get-credentials ${k8_cluster} --zone ${google_zone}
    export PGHOST=$(ip route show default | awk '/default/ {print $3}')
    export DB_DATAREPO_URI="jdbc:postgresql://${PGHOST}:5432/datarepo"
    export DB_STAIRWAY_URI="jdbc:postgresql://${PGHOST}:5432/stairway"
    eval $(cat env_var_druri)
    export GOOGLE_APPLICATION_CREDENTIALS=gcpsa.json
    pg_isready -h ${PGHOST} -p ${PGPORT}
    echo -----------------------------------
    ulimit -c unlimited
    echo -----------------------------------
    psql -U postgres -f ./db/create-data-repo-db
    # required for tests
    ./gradlew assemble
    ./gradlew check --scan
    ./gradlew testIntegration --scan
    cat /github/workspace/core
    cat /github/workspace/*.log
  fi
}
