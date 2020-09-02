#!/bin/bash

gradleperfsmoketest () {
  if [ -f env_vars ]; then
    echo "Getting GCR tags and IT_JADE_API_URL for integration test"
    eval $(cat env_vars)
  else
    echo "Skipping importing environment vars for gradleinttest"
  fi

  # hardcode data project for connected tests
  google_data_project=""

  if [[ -n "${google_project}" ]] && [[ "${google_application_credentials}" != "" ]] && [ -f ${google_application_credentials} ] && [[ "${google_application_credentials_pem}" != "" ]] && [ -f ${google_application_credentials_pem} ]; then
    export PGHOST=$(ip route show default | awk '/default/ {print $3}')
    export DB_DATAREPO_URI="jdbc:postgresql://${PGHOST}:5432/datarepo"
    export DB_STAIRWAY_URI="jdbc:postgresql://${PGHOST}:5432/stairway"
    export GOOGLE_APPLICATION_CREDENTIALS=${google_application_credentials}
    export IT_JADE_PEM_FILE_NAME=jade-dev-account.pem
    export GOOGLE_SA_CERT=${google_application_credentials_pem}
    export GOOGLE_CLOUD_PROJECT=${google_project}
    export GOOGLE_CLOUD_DATA_PROJECT=${google_data_project}
    #potentially don't need  postgres stuff
    #pg_isready -h ${PGHOST} -p ${PGPORT}
    #psql -U postgres -f ./db/create-data-repo-db

    printf "perf test\n"
    cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-client
    ../gradlew clean assemble
    cd ${GITHUB_WORKSPACE}/${workingDir}
    export ORG_GRADLE_PROJECT_datarepoclientjar=.$(ls ./datarepo-client/build/libs/*jar)
    export TEST_RUNNER_SERVER_SPECIFICATION_FILE="${NAMESPACEINUSE}.json"
    cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-clienttests      
    ./gradlew runTest --args="suites/PRSmokeTests.json tmp/TestRunnerResults"
    cd ${GITHUB_WORKSPACE}/${workingDir}
  else
    echo "missing vars for function gradleinttest"
    exit 1
  fi
}
