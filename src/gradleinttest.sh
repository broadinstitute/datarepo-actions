#!/bin/bash

gradleinttest () {
  if [ -f env_vars ] && [[ -n "${IT_JADE_API_URL}" ]] && [[ "${test_to_run}" == "testIntegration" ]]; then
    echo "Getting GCR tags and IT_JADE_API_URL for integration test"
    eval $(cat env_vars)
  else
    echo "Skipping importing environment vars for gradleinttest"
  fi
  if [[ -n "${google_project}" ]] && [ -f jade-dev-account.json ] && [ -f jade-dev-account.pem ] && [[ "${test_to_run}" != "" ]]; then
    export PGHOST=$(ip route show default | awk '/default/ {print $3}')
    export DB_DATAREPO_URI="jdbc:postgresql://${PGHOST}:5432/datarepo"
    export DB_STAIRWAY_URI="jdbc:postgresql://${PGHOST}:5432/stairway"
    export GOOGLE_APPLICATION_CREDENTIALS=jade-dev-account.json
    export IT_JADE_PEM_FILE_NAME=jade-dev-account.pem
    export GOOGLE_SA_CERT=jade-dev-account.pem
    export GOOGLE_CLOUD_PROJECT=${google_project}
    if [[ "${test_to_run}" == "testIntegration" ]]; then
      echo "Running integration tests against ${IT_JADE_API_URL}"
    fi
    pg_isready -h ${PGHOST} -p ${PGPORT}
    psql -U postgres -f ./db/create-data-repo-db
    # required for tests
    ./gradlew assemble
    ./gradlew check --scan
    ./gradlew ${test_to_run} --scan
#    ./gradlew testConnected --scan
#    ./gradlew testIntegration --scan
  else
    echo "missing vars for function gradleinttest"
    exit 1
  fi
}
